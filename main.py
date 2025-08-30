import sys
import os
import atexit
import ctypes
from typing import Optional, Tuple
from PySide6.QtWidgets import QApplication
from PySide6.QtCore import QSharedMemory, QSystemSemaphore, Qt
from PySide6.QtGui import QIcon
from ui.main_window import MainWindow
from core.ffmpeg_checker import check_ffmpeg
from core.utils import resource_path
from core.version import get_version

def set_platform_specific_settings():
    if sys.platform.startswith("win"):
        try:
            app_id = f"TubeTokDownloader.App.{get_version(short=True)}"
            ctypes.windll.shell32.SetCurrentProcessExplicitAppUserModelID(app_id)
            # Remove DPI awareness setting - Qt handles this automatically
            # ctypes.windll.shcore.SetProcessDpiAwareness(2)
        except Exception as e:
            print(f"Failed to set Windows-specific settings: {e}")

def cleanup_shared_memory(shared_mem: Optional[QSharedMemory]) -> None:
    if shared_mem:
        try:
            if shared_mem.isAttached():
                if not shared_mem.detach():
                    # Only force detach if normal detach fails
                    if hasattr(shared_mem, 'forceDetach'):
                        shared_mem.forceDetach()  # type: ignore
        except Exception as e:
            print(f"Error during shared memory cleanup: {e}")

def create_shared_memory() -> Tuple[Optional[QSharedMemory], Optional[QSystemSemaphore]]:
    if sys.platform.startswith("win"):
        shared_mem = QSharedMemory(f"TubeTok Downloader {get_version(short=True)}")
        semaphore = QSystemSemaphore(f"TubeTokDownloader_Semaphore_{get_version(short=True)}", 1)
        return shared_mem, semaphore
    return None, None

def main() -> None:
    set_platform_specific_settings()
    
    shared_mem, semaphore = create_shared_memory()
    
    if shared_mem:
        atexit.register(cleanup_shared_memory, shared_mem)
        
        if not shared_mem.create(1):
            app = QApplication.instance()
            if app is None:
                app = QApplication(sys.argv)
            
            if hasattr(app, 'topLevelWidgets'):
                for widget in app.topLevelWidgets():  # type: ignore
                    if isinstance(widget, MainWindow):
                        if widget.isMinimized():
                            widget.showNormal()
                        if hasattr(Qt, 'WindowMinimized'):
                            widget.setWindowState(widget.windowState() & ~Qt.WindowMinimized)  # type: ignore
                    widget.activateWindow()
                    widget.raise_()
                    widget.show()
                    return
            # No existing window found -> likely stale shared memory; clean and continue
            try:
                if not shared_mem.detach():
                    if hasattr(shared_mem, 'forceDetach'):
                        shared_mem.forceDetach()  # type: ignore
            except Exception as e:
                print(f"Stale shared memory cleanup failed: {e}")
    
    app = QApplication(sys.argv)
    
    icon_path = resource_path(os.path.join("assets", "app.ico"))
    if os.path.exists(icon_path):
        app_icon = QIcon(icon_path)
        app.setWindowIcon(app_icon)
    
    ffmpeg_found, ffmpeg_path = check_ffmpeg()
    if not ffmpeg_found:
        print("FFmpeg not found. Please ensure it is installed and in PATH.")
    else:
        print(f"FFmpeg found at: {ffmpeg_path}")
    
    win = MainWindow(ffmpeg_found=ffmpeg_found, ffmpeg_path=ffmpeg_path)
    
    if os.path.exists(icon_path):
        win.setWindowIcon(app_icon)
    
    def cleanup():
        if shared_mem:
            cleanup_shared_memory(shared_mem)
        if semaphore and semaphore.acquire():
            semaphore.release()

    if shared_mem:
        atexit.register(cleanup)
    
    win.show()
    sys.exit(app.exec())

if __name__ == "__main__":
    main()
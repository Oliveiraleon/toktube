# 📜 Qt / PySide6 License Notice

This project uses **PySide6 (Qt for Python)**, which is licensed under the **GNU Lesser General Public License v3.0 (LGPL-3.0)**.
The LGPL-3.0 license permits the use, modification, and distribution of this software, provided that users retain the freedom to modify and relink Qt components independently.

🔗 Full license text: [https://www.gnu.org/licenses/lgpl-3.0.html](https://www.gnu.org/licenses/lgpl-3.0.html)

---

## 🤩 Distribution Strategy & Compliance

To comply with LGPL-3.0 while maintaining usability, YouTubeGO provides:

### Windows

* `TubeTokDownloader.exe`
  → Onefile standalone build, intended for convenience

* `TubeTokDownloader-Win.zip`
  → Contains:

  * `onedir` build (includes `TubeTokDownloader.exe`, Qt DLLs, assets, and themes)
  * This license notice
  * GNU GPL v3 license

This distribution allows users to inspect and rebuild the application using their own versions of the Qt libraries.
While the onefile format embeds Qt components for ease of use, full source code is provided to allow custom builds that link against user-modified Qt libraries if desired.

### macOS

* `TubeTokDownloader.dmg`
  → Contains:
  
  * macOS application bundle with Qt frameworks

  
This distribution provides the Qt frameworks in a way that allows users to replace them with their own versions if needed.

### Linux

* `YoutubeGo-x86_64.AppImage`
  → Self-contained application that includes:
  
  * Qt libraries and dependencies

The AppImage format allows users to extract the contents and rebuild with their own Qt libraries as needed.

---

## 🛠️ Source & Rebuild Instructions

* The complete source code is available at:
  🔗 [https://github.com/erfukuby/toktube](https://github.com/erfukuby/toktube)

* Users may uninstall PySide6, install an alternative version, and rebuild with `pyinstaller` using the provided `main.py` and configuration.

Example:

```bash
pip uninstall PySide6
pip install PySide6==[your_version]
pyinstaller ...
```

No additional documentation is required.

---

## 🛡️ Licensing Summary

* The core application **YouTubeGO** is licensed under the **GNU GPL v3**.
* PySide6 (Qt) components are licensed under the **LGPL-3.0**.

This project ensures compliance by making both source code and dynamic linking structure available through the `onedir` format.




---

> **Trademarks Notice:**
> "Qt", "Qt for Python", and the Qt logo are trademarks of **The Qt Company Ltd.**, registered in Finland and/or other countries.
> This project is **not affiliated with, endorsed by, or sponsored by The Qt Company**.


Disclaimer: This license notice is provided in good faith to meet the obligations of LGPL-3.0 and ensure transparency. However, it does not constitute legal advice. For full legal interpretation, refer to the official license text or consult a legal professional.


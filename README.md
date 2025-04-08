sd-webui-installer Wiki
=======================

**sd-webui-installer** is a comprehensive PowerShell installer for AUTOMATIC1111’s Stable Diffusion WebUI on Windows. This installer automatically handles:

*   Installation of prerequisites: Git and Python 3.10
*   Cloning/updating the Stable Diffusion WebUI repository
*   Setting up a Python virtual environment with CUDA‑enabled PyTorch and xformers
*   Downloading the recommended model checkpoint
*   Configuring performance flags and launching the WebUI

* * *

Installation Instructions
-------------------------

1.  **Clone the Repository:**
    
    Clone the repository using Git:
    
        git clone https://github.com/<your-username>/sd-webui-installer.git
        cd sd-webui-installer
    
2.  **Run the Installer:**
    
    Open an elevated PowerShell window (Run as Administrator) and execute:
    
        .\INSTALL-SDWEBUI.ps1
    
    When prompted, press Enter to accept the default installation directory or specify your own.
    
3.  **Follow On-screen Instructions:**
    
    The script will verify system prerequisites, install dependencies, and launch the WebUI at [http://127.0.0.1:7860](http://127.0.0.1:7860).
    

* * *

Troubleshooting
---------------

*   **Insufficient Disk Space:** Ensure your installation drive has at least 10GB free.
*   **Git or Python Installation Issues:** Verify that Git and Python 3.10 are installed and in your PATH.
*   **Virtual Environment Issues:** If you encounter errors with the virtual environment, delete the `venv` folder in the installation directory and re-run the installer.
*   **Repository Update Issues:** If you see errors related to "dubious ownership," verify that the Git `safe.directory` setting is applied correctly.
*   **WebUI Fails to Launch:** Check the PowerShell log output for errors and review the installer output.

* * *

Frequently Asked Questions (FAQ)
--------------------------------

**Which GPU is supported?**

This installer has been tested with NVIDIA RTX 4080 (PNY variant) and should work with similar CUDA‑capable GPUs.

**Can I re-run the installer?**

Yes. The script detects existing installations and will update the repository, re-use the virtual environment, and only re-download files if necessary.

**What if the WebUI fails to launch?**

Please check the log output in the PowerShell window for errors, and consult the Troubleshooting section above.

* * *

Contributing
------------

Contributions to **sd-webui-installer** are welcome! If you have suggestions, improvements, or bug fixes, please follow these steps:

1.  Fork the repository on GitHub.
2.  Create a new branch:
    
        git checkout -b feature/YourFeatureName
    
3.  Commit your changes with clear messages.
4.  Push your branch and open a pull request for review.

Before contributing, please review any existing [open issues](https://github.com/<your-username>/sd-webui-installer/issues) and the repository guidelines.

* * *

License
-------

Specify your repository’s license here. For example, you might choose the MIT License, Apache 2.0, etc.

* * *

© 2023 sd-webui-installer. All rights reserved.

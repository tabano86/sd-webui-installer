<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>sd-webui-installer Wiki</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      max-width: 800px;
      margin: auto;
      line-height: 1.6;
      padding: 20px;
    }
    h1, h2, h3 {
      color: #2C3E50;
    }
    pre {
      background-color: #F4F4F4;
      padding: 10px;
      border: 1px solid #ddd;
      overflow-x: auto;
    }
    code {
      font-family: Consolas, "Courier New", monospace;
    }
    a {
      color: #3498DB;
    }
  </style>
</head>
<body>
  <h1>sd-webui-installer Wiki</h1>
  <p>
    <strong>sd-webui-installer</strong> is a comprehensive PowerShell installer for AUTOMATIC1111’s Stable Diffusion WebUI on Windows.
    This installer automatically handles:
  </p>
  <ul>
    <li>Installation of prerequisites: Git and Python 3.10</li>
    <li>Cloning/updating the Stable Diffusion WebUI repository</li>
    <li>Setting up a Python virtual environment with CUDA‑enabled PyTorch and xformers</li>
    <li>Downloading the recommended model checkpoint</li>
    <li>Configuring performance flags and launching the WebUI</li>
  </ul>

  <hr>

  <h2>Installation Instructions</h2>
  <ol>
    <li>
      <strong>Clone the Repository:</strong>
      <p>
        Clone the repository using Git:
      </p>
      <pre><code>git clone https://github.com/&lt;your-username&gt;/sd-webui-installer.git
cd sd-webui-installer</code></pre>
    </li>
    <li>
      <strong>Run the Installer:</strong>
      <p>
        Open an elevated PowerShell window (Run as Administrator) and execute:
      </p>
      <pre><code>.\INSTALL-SDWEBUI.ps1</code></pre>
      <p>
        When prompted, press Enter to accept the default installation directory or specify your own.
      </p>
    </li>
    <li>
      <strong>Follow On-screen Instructions:</strong>
      <p>
        The script will verify system prerequisites, install dependencies, and launch the WebUI at <a href="http://127.0.0.1:7860" target="_blank">http://127.0.0.1:7860</a>.
      </p>
    </li>
  </ol>

  <hr>

  <h2>Troubleshooting</h2>
  <ul>
    <li>
      <strong>Insufficient Disk Space:</strong> Ensure your installation drive has at least 10GB free.
    </li>
    <li>
      <strong>Git or Python Installation Issues:</strong> Verify that Git and Python 3.10 are installed and in your PATH.
    </li>
    <li>
      <strong>Virtual Environment Issues:</strong> If you encounter errors with the virtual environment, delete the <code>venv</code> folder in the installation directory and re-run the installer.
    </li>
    <li>
      <strong>Repository Update Issues:</strong> If you see errors related to "dubious ownership," verify that the Git <code>safe.directory</code> setting is applied correctly.
    </li>
    <li>
      <strong>WebUI Fails to Launch:</strong> Check the PowerShell log output for errors and review the installer output.
    </li>
  </ul>

  <hr>

  <h2>Frequently Asked Questions (FAQ)</h2>
  <dl>
    <dt><strong>Which GPU is supported?</strong></dt>
    <dd>This installer has been tested with NVIDIA RTX 4080 (PNY variant) and should work with similar CUDA‑capable GPUs.</dd>
    <dt><strong>Can I re-run the installer?</strong></dt>
    <dd>Yes. The script detects existing installations and will update the repository, re-use the virtual environment, and only re-download files if necessary.</dd>
    <dt><strong>What if the WebUI fails to launch?</strong></dt>
    <dd>Please check the log output in the PowerShell window for errors, and consult the Troubleshooting section above.</dd>
  </dl>

  <hr>

  <h2>Contributing</h2>
  <p>
    Contributions to <strong>sd-webui-installer</strong> are welcome! If you have suggestions, improvements, or bug fixes, please follow these steps:
  </p>
  <ol>
    <li>Fork the repository on GitHub.</li>
    <li>Create a new branch:
      <pre><code>git checkout -b feature/YourFeatureName</code></pre>
    </li>
    <li>Commit your changes with clear messages.</li>
    <li>Push your branch and open a pull request for review.</li>
  </ol>
  <p>
    Before contributing, please review any existing <a href="https://github.com/&lt;your-username&gt;/sd-webui-installer/issues" target="_blank">open issues</a> and the repository guidelines.
  </p>

  <hr>

  <h2>License</h2>
  <p>
    Specify your repository’s license here. For example, you might choose the MIT License, Apache 2.0, etc.
  </p>

  <hr>

  <p style="text-align: center;">
    &copy; 2023 sd-webui-installer. All rights reserved.
  </p>
</body>
</html>

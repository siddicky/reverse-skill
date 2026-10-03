# Installation and Download Safety Guidelines

## Prefer using uv to manage Python environment

Standalone command line tools can be installed using `uv tool install <package>`. For project dependencies, create a virtual environment first:

    uv venv
    uv pip install -r requirements.txt

Don't mechanically replace all `pip` instructions. `uv pip` is suitable for established virtual environments, while standalone CLI tools are usually better suited using `uv tool install`. To improve reproducibility, please try to fix dependency versions or submit a lock file.

## Safe handling of downloaded zip files

Reverse engineering and security testing tools may contain binaries, debuggers, packaging files or security testing data, which can easily trigger heuristic detection by anti-virus software. Antivirus warnings do not mean that security has been proven, nor that malicious intent has been proven.

Don't disable your anti-virus software or blindly ignore warnings. Before opening the compressed file, please confirm that the file comes from the expected HTTPS repository or release page; if there is a checksum or release digest, please compare it first; then check the contents of the compressed file and scan it with the latest security software. Do not directly execute unknown binaries, scripts or installers just because the file downloaded successfully.

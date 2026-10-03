# reverse-skill quick start and community problem explanation

## Project positioning

`reverse-skill` is a collection of reverse engineering, security research skills, rules and tool files that can be read by the AI ​​client. It is not a single executable application. Before use, please confirm that you have explicit authorization for the analysis target or are using a legal CTF, teaching or testing environment.

## Basic usage

Download the project first:

    git clone https://github.com/zhaoxuya520/reverse-skill.git
    cd reverse-skill

Then give the project directory to the AI ​​client you are using as a workspace or file source. Core files include:

- `RULES.md`: General rules and safety boundaries.
- `skills/MASTER-ROUTING.md`: Skill routing and task offloading.
- `skills/*/SKILL.md`: Description of skills in each professional field.
- `docs/platforms/`: Tool installation instructions for different operating systems.

This project remains client-neutral, so the actual loading methods of OpenCode, Codex, Cursor, Claude Code and other clients are still subject to the official documents of each client; do not assume that the plugin or synchronization format of a certain client can be applied to other clients.

The most reliable general approach is to open the entire repository root directory as a workspace, rather than just copying the `skills/` subdirectory into the client. Confirm that the client can read `AGENTS.md` / `RULES.md` in the root directory, and then execute the platform's native `master-route`; if the client does not automatically load the project rules, explicitly reference `RULES.md` and the target `SKILL.md` in the conversation.

## OpenCode, Codex and synchronization issues

If the client displays `Not Synchronizable` or cannot be synchronized, first confirm whether the workspace points to the complete repository root directory, whether the file permissions allow reading, and whether the client supports the directory format. The most reliable alternative is to open the repository directly in the local workspace and explicitly reference the required rules or skill files in the conversation. If the problem can still be reproduced, please include the client version, operating system, complete error message, and minimum reproduction steps when reporting.

## AI refuses to process analysis request

AI's security policy will not necessarily allow all operations just because "I have authorized" is added to the prompt. Please process only legitimately authorized targets and avoid requests for unauthorized intrusion, credential theft, persistence, or destructive operations; you can limit requests to code understanding, sample analysis, vulnerability patching, CTF, or defensive verification. For a specific APK, website, or account, please first prepare verifiable authorization scope and test environment.

## Python tools and uv

Standalone command line tools are available:

    uv tool install PACKAGE_NAME

Project dependencies use isolation environments:

    uv venv
    uv pip install -r requirements.txt

Don't mechanically replace all `pip` strings with `uv pip`; `python -m pip`, `pipx` bootstrap and existing virtual environments each have different uses. If `uv` is not installed yet, please use the operating system package manager or an explicitly created virtual environment. Do not install security tools directly into system-wide Python.

For more complete installation and compressed file security instructions, see [Installation and Download Security Guidelines] (UV-AND-DOWNLOAD-SECURITY_zh.md).

## ZIP virus reporting and download security

Reverse engineering tools may contain binaries, debuggers, packaging files or test data, which can easily trigger heuristic detection by anti-virus software. Antivirus warnings do not mean that security has been proven, nor that malicious intent has been proven. Don't disable your anti-virus software or blindly ignore warnings.

Before opening the archive, please download it from the expected HTTPS repository or release page, check the checksum or release digest (if provided), check the archive contents, and scan with the latest security software. Do not directly execute unknown binaries, scripts or installers just because the file downloaded successfully.

## Accounts, Contributions and Unspecified Returns

Please comply with the terms of service of the AI ​​client, GitHub, tool vendor, and target environment. The repository itself cannot guarantee that third-party platforms will not restrict accounts, nor can it determine account policies for the platform. To contribute radare2 or other skills, please first read `skills/CONTRIBUTING.md` and submit as a small, verifiable Pull Request.

Only issues that contain a complete error message, environment information, and reproduction steps are suitable for further repair. For reports with only "virus", "gaha" or "test", please add the file name, download URL, scan product, version and reproduction method.

## External models and APIs

This repository does not build, proxy, or resell the Grok/xAI API, and does not collect or distribute Grok API keys. Models and API endpoints are configured by users in the selected AI client or provider; when using third-party forwarding services, please check the provider, data processing terms, and key risks yourself.

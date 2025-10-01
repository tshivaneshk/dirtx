dirtx - CLI Folder Organizer

dirtx is a professional command-line tool that automatically organizes your files into categories such as Images, Videos, Documents, Code, WebApps, Archives, and more.

It helps keep your folders clean and manageable with just a single command.

Features
--> Automatically organizes files into categories
--> Detects and skips already organized folders
--> Dry-run mode (see changes before applying)
--> Move files older than N days
--> Unicode banner for a professional look
--> Global installation for system-wide CLI usage

Installation

Clone the repo and run the setup script:

git clone https://github.com/tshivaneshk/dirtx.git
cd dirtx
chmod +x setup.sh
./setup.sh


This will install dirtx globally so you can use it from anywhere.

Usage

Run dirtx in any folder you want to organize:

dirtx

Example with options:

dirtx --dry-run        # Show what will happen without moving files
dirtx --days 30        # Move only files older than 30 days

📜 License

This project is licensed under the MIT License.
See the LICENSE file for details.

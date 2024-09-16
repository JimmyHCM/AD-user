# Active Directory User Creation Script

This PowerShell script automates the process of creating new users in Active Directory and configuring their Exchange Online mailboxes.

## Prerequisites

- Windows PowerShell 5.1 or later
- Active Directory module for Windows PowerShell
- Exchange Online Management module
- Administrator access to your Active Directory environment
- Exchange Online administrator account

## Setup

1. Run PowerShell ISE as an administrator.

2. Install the Exchange Online Management module by running:

   ```powershell
   Install-Module -Name ExchangeOnlineManagement -Force -AllowClobber
   ```

3. Prepare the input files:

   a. Create a CSV file named `newusers.csv` with the following structure:

      ```
      username,password,firstname,lastname,groups
      harrypotter,12344321,harry,potter,group1#group2
      ```

      Note: Separate multiple groups with a '#' character.

   b. Create a text file named `uid.txt` containing a starting UID number for Unix attributes.

4. Place both files in the `C:\scripts\` directory (or modify the script to point to your preferred location).

## Usage

1. Open the script in PowerShell ISE.

2. Review and modify any configuration settings if necessary (e.g., UPN suffix, file paths).

3. Run the script.

4. When prompted, log in with your Exchange Online administrator account.

## Script Behavior

- The script will create new users in Active Directory based on the information in `newusers.csv`.
- It will set various attributes including Unix attributes and Exchange mailbox settings.
- Users will be added to the specified groups (if the groups exist).
- The script will automatically increment and update the UID number in `uid.txt`.
- A log file (`user_creation_log.txt`) will be created in the same directory as the script, detailing the actions performed.

## Important Notes

- Always test the script in a non-production environment before using it in production.
- Ensure that the groups specified in the CSV file exist in Active Directory.
- The script sets passwords to never expire. Modify this setting if it doesn't align with your security policies.
- Review and adjust the Unix attributes (like gidNumber) to match your environment's requirements.

## Troubleshooting

- If you encounter module import errors, ensure that you have the necessary permissions and that the modules are installed correctly.
- Check the log file for detailed information about any errors or issues encountered during execution.

## Contributing

Feel free to fork this repository and submit pull requests for any enhancements or bug fixes.

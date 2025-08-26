# n8n Backup and Retrieval Workflows

This project contains a set of n8n workflows that automatically **back up** and **retrieve** your n8n workflows and credentials with GitHub integration.

These workflows are essential if you are running n8n locally, because without them you risk losing all your data if something goes wrong. With backups in GitHub, you can always restore your work safely. Retrieval workflows make the process two-way, ensuring you can also restore workflows and credentials back into n8n when required.

---

## Workflows Included

### 1. n8n-Workflows-Backup
- Backs up all your n8n workflows to a GitHub repository.  
- Requires the **n8n API** to be enabled. (Refer to the [n8n documentation](https://docs.n8n.io) for setup details.)  

### 2. n8n-Credentials-Backup
- Backs up your n8n credentials to a GitHub repository.  
- Since credentials are sensitive, always use a **private GitHub repository** for this backup.  

### 3. n8n-Backup (Combined Workflow)
- A single workflow that performs both:  
  - Workflows Backup  
  - Credentials Backup  
- Ideal if you want a one-click solution for backing up everything together.  

### 4. n8n-Workflow-Retrieval
- Retrieves workflows from GitHub and creates them in n8n.  
- Requires access to **GitHub** and **n8n** only.  
- Useful for restoring workflows or syncing them across different n8n instances.  

### 5. n8n-Credentials-Retrieval
- Retrieves credentials from GitHub and creates them in n8n.  
- Requires access to **GitHub**, **n8n**, and a **Google Sheet** for mapping.  
- The Google Sheet should contain three columns:  
  1. **ID in GitHub**  
  2. **ID in n8n**  
  3. **Match Formula**:  
     ```excel
     =IF(AND($A2<>$B2, $B2<>""), "No", "Yes")
     ```  
- This mapping ensures credentials are correctly matched and restored without duplication.  

---

## Getting Started

1. **Create GitHub Repositories**  
   - For **Workflows Backup**: use a private repository if your workflows are confidential.  
   - For **Credentials Backup**: always use a private repository.  

2. **Generate a GitHub Personal Access Token**  
   - Create a token with **repo** permissions (see GitHub documentation for details).  

3. **Import and Configure Workflows in n8n**  
   - Import the workflow you need.  
   - Add your GitHub repository URL, branch, and personal access token.  
   - For **Workflows Backup**, also configure your n8n API connection (see [n8n API docs](https://docs.n8n.io)).  
   - For **Credentials Retrieval**, configure access to your Google Sheet for ID mapping.  

4. **Run or Schedule**  
   - Backups: Trigger manually or schedule with Cron inside n8n.  
   - Retrievals: Run whenever you need to restore workflows or credentials.  

---

## Security Notes

- Always back up credentials in a private repository.  
- If workflows contain sensitive information, use a private repository as well.  
- Never share your GitHub personal access token or credentials publicly.  
- Avoid backing up workflows with **pinned data**, as this may unintentionally expose personal keys or sensitive information.  

---

## Summary

With these workflows, you can:  
- Back up your n8n workflows and credentials to GitHub.  
- Retrieve workflows and credentials from GitHub into n8n.  
- Keep everything version-controlled, recoverable, and portable.  
- Avoid losing your data — especially important if you run n8n locally.  
- Use **n8n-Backup** for an all-in-one backup solution.  
- Use **n8n-Workflow-Retrieval** and **n8n-Credentials-Retrieval** for reliable restoration when needed.  

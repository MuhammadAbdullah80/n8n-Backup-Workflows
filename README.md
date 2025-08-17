# n8n Backup Workflows

This project contains three n8n workflows that automatically back up your **n8n workflows** and **credentials** to GitHub.

These backups are essential if you are running n8n locally, because without them you risk losing all your data if something goes wrong. With backups in GitHub, you can always restore your work safely.

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

4. **Run or Schedule Backups**  
   - Trigger manually or schedule with Cron inside n8n.  

---

## Security Notes

- Always back up credentials in a private repository.  
- If workflows contain sensitive information, use a private repository as well.  
- Never share your GitHub personal access token or credentials publicly.  

---

## Summary

With these workflows, you can:  
- Back up your n8n workflows and credentials to GitHub.  
- Keep everything version-controlled and recoverable.  
- Avoid losing your data — especially important if you run n8n locally.  
- Use **n8n-Backup** for a simple all-in-one backup solution.

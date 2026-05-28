edit by brice
---

#  Installation Guide & Troubleshooting

## 1. Documentation Overview

This project uses **Docusaurus**, a modern static website generator based on React. It allows us to centralize, structure, and maintain all of Melomania's technical documentation.

The application is part of a comprehensive architecture that includes:

* A **Frontend** and a **Backend** for the main application.
* A **Database (PostgreSQL)** and a database management tool (**Adminer**), both orchestrated via Docker to ensure a consistent environment for all developers.

---

## 2. Prerequisites & Local Setup

To run the documentation locally, follow these steps:

```bash
# 1. Install dependencies (Node.js v22 or v24 LTS is mandatory)
npm install

# 2. Start the local development server
npm run start

```

The site will then be accessible at `http://localhost:3000`.

---

## 3. Common Troubleshooting

### Issue: Port Already in Use

If you receive an error indicating that port 3000 is already in use, you can either:

* Close the application currently using this port.
* Start Docusaurus on a different port using the following command:
```bash
PORT=3001 npm run start

```



### Issue: Compilation Errors

If you encounter compilation errors during setup, ensure that:

* You are using a compatible version of Node.js (v22 or v24 LTS).
* All dependencies are correctly installed (try running `npm install` again).
* You check the error logs to identify any missing modules or version conflicts.
* If the issue persists, consult the official Docusaurus documentation or open an issue on the project's repository.

### Issue: Styling or Layout Problems

If the site does not render correctly, try the following:

* Clear your browser cache.
* Check any custom CSS files for syntax errors.
* Ensure that images and other assets are correctly referenced within your Markdown files.

### Issue: Deployment Failures

If you have trouble deploying the documentation, make sure that:

* You have properly configured the environment variables for your deployment platform (e.g., Netlify, Vercel).
* You build the site locally before deploying to check for errors:
```bash
npm run build

```


* You review the deployment logs to identify specific errors and adjust your configuration accordingly.

### Issue: Navigation or Broken Links

* If internal links are broken, verify that the file paths in your Markdown files are accurate.
* Ensure the referenced files exist and are correctly located within the project structure.
* Use relative paths for internal links to prevent navigation issues.

### Issue: Performance Bottlenecks

* If the site loads slowly, inspect the used resources (images, scripts) and optimize them if necessary.
* Ensure your machine has sufficient resources allocated to run the local server.
* Use browser developer tools to identify bottlenecks during page load and optimize accordingly.

### Issue: Docusaurus Version Conflicts

* If you encounter issues related to the Docusaurus version, ensure it remains compatible with the other project dependencies.
* Consult the official Docusaurus release notes for major changes that might affect the project.
* When in doubt, try updating Docusaurus and other dependencies to their latest stable versions:
```bash
npm update

```



### Issue: MDX Compilation Error (Unexpected character !)

* **Symptom:** The Docusaurus build crashes at startup due to a file located in the `/blog` directory.
* **Cause:** Recent versions of Docusaurus no longer support classic HTML comments.
* **Solution:** Open the affected blog files and replace the old HTML tag `` with the modern MDX syntax `{/* truncate */}`.

### Issue: Docker Image Pull Failure (EOF / failed to copy)

If the `docker compose up` command fails while pulling the `postgres` or `adminer` images:

1. First, stop the containers and clean up any partial downloads:
```bash
docker compose down
docker system prune -f

```


2. Next, try pulling the images manually one by one:
```bash
docker pull postgres
docker pull adminer

```


3. Once both are successfully downloaded, start the services:
```bash
docker compose up -d

```
###  Docker Image Pull Failure (`EOF` / `failed to copy`)
* **Symptom:** The `docker compose up` or `docker pull` command crashes abruptly (`EOF` error) while pulling the `postgres` or `adminer` images.
* **Common causes:** Unstable experimental `containerd` feature on Windows, network saturation due to concurrent downloads, or a restrictive firewall.
* **Solutions (try in order):**
    1. **Disable containerd (Recommended on Windows):**
        * Open Docker Desktop > **Settings** (Gear icon) > **General**.
        * Uncheck the **"Use containerd for pulling and storing images"** option.
        * Click **Apply & restart** and try a manual `docker pull` again.
    2. **Limit concurrent downloads:**
        * Go to Docker Desktop > **Settings** > **Docker Engine**.
        * Add the line `"max-concurrent-downloads": 1,` to the JSON configuration.
        * Click **Apply & restart**.
    3. **Cleanup and Manual Pull:**
       If the download was corrupted, clear the cache before trying again:
       ```bash
       docker compose down
       docker system prune -f
       docker pull postgres
       docker pull adminer
       ```
    4. **Alternative Network:** If the error persists on your home router or corporate/university network, temporarily use a 4G/5G mobile hotspot to download the images to 100%.


*Note: If the process continues to fail, try switching to a different network (e.g., a mobile hotspot), as restrictive corporate or university networks sometimes block Docker image downloads.*
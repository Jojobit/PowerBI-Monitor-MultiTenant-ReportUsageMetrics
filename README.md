# PowerBIMonitorReportUsageMetrics
Generate and fetch data from Power BI usage metrics across workspaces and tenants

## Introduction 📊

Welcome to PowerBIMonitorReportUsageMetrics! This PowerShell script helps you to monitor and analyze the usage metrics of your Power BI reports across multiple workspaces and tenants. The aim is to provide a deeper understanding of how your Power BI reports are utilized, which can guide you in your Power BI user adoption journey.

## Features 🔍

- Checks if the required Power BI management modules are installed.
- Authenticates and connects to the Power BI service for each tenant.
- Generates workspace usage metrics.
- Fetches and exports data for reports, users, report pages, views and view types to CSV files. Everything that you have in the Usage Metrics reports in Power BI Service 😉

## Pre-requisites 🛠

- PowerShell. If you need help, check out [New Stars of Data 2023](https://github.com/Jojobit/Speaking/tree/bcfd8393332398d482756ee7cead7f506bb445e9/New%20Stars%20of%20Data%202023)
- Valid credentials in the form of username and password for Power BI for each tenant you intend to monitor.

## How to Use 🚀

1. Clone this repository to your local machine.
2. Populate the `tenants` folder with text files for each tenant. Each text file should be name Tenant.txt (where Tenant is the name you call the tenant) and contain the username on the first line and password on the second line.
3. Run the script from PowerShell.

## Output Files 🗂

- `um_workspaces.csv` - Contains information about processed workspaces.
- `um_reports.csv` - Contains report data.
- `um_users.csv` - Contains user data.
- `um_reportpages.csv` - Contains report page data.
- `um_workspaceviews.csv` - Contains workspace view data.
- `um_reportviews.csv` - Contains report view data.
- `um_reportpageviews.csv` - Contains report page view data.
- `um_reportloadtimes.csv` - Contains report load time data.
- `um_errors.csv` - Contains any errors during processing.

## Note 📝

- The script uses sleep function to wait 10 seconds between API calls to avoid rate-limiting issues. 
- It exports all the gathered data to CSV files for easy consumption.
- Every subsequent run will append to the existing CSV files.

## Let's #BuildSomethingAwesome Together! 🌟

Feel free to contribute or report issues. Your feedback is always welcome! 

Happy Monitoring! 😊


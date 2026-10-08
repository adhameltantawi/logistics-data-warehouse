# ==============================================================================
# run_pipeline.ps1  —  Logistics Data Warehouse: End-to-End Pipeline Runner
# ==============================================================================
# Description:
#   Executes the complete logistics_dwh pipeline from scratch using sqlcmd.
#   Runs all three layers in correct dependency order:
#       0. Database init
#       1. Bronze layer  (DDL + load)
#       2. Silver layer  (DDL + load)
#       3. Gold layer    (DDL + load)
#       4. Analytics     (KPI views)
#       5. Indexes + FK  (performance & integrity)
#
# Prerequisites:
#   - SQL Server (2019+) installed and running
#   - sqlcmd installed (comes with SQL Server or SSMS)
#   - Your SQL login must have:  sysadmin  OR  dbcreator + bulkadmin roles
#   - CSV datasets placed in datasets\  as per the project structure
#
# Usage:
#   .\run_pipeline.ps1                          # Uses defaults below
#   .\run_pipeline.ps1 -Server ".\SQLEXPRESS"   # Custom server instance
#   .\run_pipeline.ps1 -Server "MyServer" -User "sa" -Password "secret"
#
# ==============================================================================

param(
    [string]$Server   = ".",          # SQL Server instance  (. = local default)
    [string]$Database = "master",     # Init script runs against master
    [string]$User     = "",           # Leave blank for Windows Authentication
    [string]$Password = ""
)

# --------------------------------------------------------------------------
# Helpers
# --------------------------------------------------------------------------
$ErrorActionPreference = "Stop"
$ScriptRoot = $PSScriptRoot

function Write-Header($msg) {
    Write-Host ""
    Write-Host "=============================================================" -ForegroundColor Cyan
    Write-Host "  $msg" -ForegroundColor Cyan
    Write-Host "=============================================================" -ForegroundColor Cyan
}

function Write-Step($msg) {
    Write-Host "  >> $msg" -ForegroundColor Yellow
}

function Run-SqlScript($scriptPath, $dbName = "logistics_dwh") {
    $rel = $scriptPath.Replace($ScriptRoot, "").TrimStart("\")
    Write-Step "Running: $rel"

    # Build sqlcmd arguments
    $args = @("-S", $Server, "-d", $dbName, "-i", $scriptPath, "-b")
    if ($User -ne "") {
        $args += @("-U", $User, "-P", $Password)
    }

    $result = & sqlcmd @args 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  [FAILED] $rel" -ForegroundColor Red
        Write-Host $result -ForegroundColor Red
        throw "sqlcmd exited with code $LASTEXITCODE on: $rel"
    }
    Write-Host "  [OK]     $rel" -ForegroundColor Green
}

# --------------------------------------------------------------------------
# Validate sqlcmd is available
# --------------------------------------------------------------------------
if (-not (Get-Command "sqlcmd" -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: sqlcmd not found. Install SQL Server or SSMS and ensure sqlcmd is in PATH." -ForegroundColor Red
    exit 1
}

$StartTime = Get-Date
Write-Header "Logistics Data Warehouse — Pipeline Runner"
Write-Host "  Server : $Server"
Write-Host "  Auth   : $(if ($User -eq '') { 'Windows Authentication' } else { "SQL Login ($User)" })"
Write-Host "  Started: $StartTime"

# ==========================================================================
# Step 0 — Database Initialisation (runs against master)
# ==========================================================================
Write-Header "Step 0 — Database Initialisation"
Run-SqlScript "$ScriptRoot\scripts\init_database.sql" "master"

# ==========================================================================
# Step 1 — Bronze Layer
# ==========================================================================
Write-Header "Step 1 — Bronze Layer (Raw Ingestion)"

$bronzeScripts = @(
    "scripts\bronze\01_create_reference.sql",
    "scripts\bronze\02_create_transactions.sql",
    "scripts\bronze\03_create_analytics.sql",
    "scripts\bronze\04_load_reference.sql",
    "scripts\bronze\05_load_transactions.sql",
    "scripts\bronze\06_load_analytics.sql",
    "scripts\bronze\07_load_bronze_layer.sql",
    "scripts\bronze\08_create_pipeline_log.sql"
)

foreach ($script in $bronzeScripts) {
    Run-SqlScript "$ScriptRoot\$script"
}

# ==========================================================================
# Step 2 — Silver Layer
# ==========================================================================
Write-Header "Step 2 — Silver Layer (Cleanse & Standardise)"

$silverScripts = @(
    "scripts\silver\01_create_reference.sql",
    "scripts\silver\02_create_transactions.sql",
    "scripts\silver\03_create_analytics.sql",
    "scripts\silver\04_load_drivers.sql",
    "scripts\silver\05_load_customers.sql",
    "scripts\silver\06_load_facilities.sql",
    "scripts\silver\07_load_routes.sql",
    "scripts\silver\08_load_trailers.sql",
    "scripts\silver\09_load_trucks.sql",
    "scripts\silver\10_load_delivery_events.sql",
    "scripts\silver\11_load_fuel_purchases.sql",
    "scripts\silver\12_load_loads.sql",
    "scripts\silver\13_load_maintenance_records.sql",
    "scripts\silver\14_load_safety_incidents.sql",
    "scripts\silver\15_load_trips.sql",
    "scripts\silver\16_load_driver_monthly_metrics.sql",
    "scripts\silver\17_load_truck_utilization_metrics.sql",
    "scripts\silver\18_load_silver_layer.sql",
    "scripts\silver\19_load_single_table.sql"
)

foreach ($script in $silverScripts) {
    Run-SqlScript "$ScriptRoot\$script"
}

# ==========================================================================
# Step 3 — Gold Layer
# ==========================================================================
Write-Header "Step 3 — Gold Layer (Star Schema)"

$goldScripts = @(
    "scripts\gold\01_create_dimensions.sql",
    "scripts\gold\02_create_facts.sql",
    "scripts\gold\03_load_dimensions.sql",
    "scripts\gold\04_load_facts.sql",
    "scripts\gold\05_load_gold_layer.sql",
    "scripts\gold\06_create_indexes.sql",
    "scripts\gold\07_create_fk_constraints.sql",
    "scripts\gold\08_scd2_dim_driver.sql",
    "scripts\gold\09_extended_properties.sql"
)

foreach ($script in $goldScripts) {
    Run-SqlScript "$ScriptRoot\$script"
}

# ==========================================================================
# Step 4 — Analytics Layer (KPI Views)
# ==========================================================================
Write-Header "Step 4 — Analytics Layer (KPI Views)"

$analyticsScripts = @(
    "scripts\analytics\02_create_kpi_views.sql"
)

foreach ($script in $analyticsScripts) {
    Run-SqlScript "$ScriptRoot\$script"
}

# ==========================================================================
# Done
# ==========================================================================
$EndTime  = Get-Date
$Duration = [math]::Round(($EndTime - $StartTime).TotalSeconds, 1)

Write-Header "Pipeline Complete"
Write-Host "  Finished : $EndTime"  -ForegroundColor Green
Write-Host "  Duration : ${Duration}s" -ForegroundColor Green
Write-Host ""
Write-Host "  Next steps:" -ForegroundColor White
Write-Host "    1. Run tests\bronze\01_quality_checks_bronze.sql" -ForegroundColor White
Write-Host "    2. Run tests\silver\ quality check scripts" -ForegroundColor White
Write-Host "    3. Run tests\gold\   quality check scripts" -ForegroundColor White
Write-Host "    4. Run scripts\analytics\01_business_questions.sql" -ForegroundColor White
Write-Host ""

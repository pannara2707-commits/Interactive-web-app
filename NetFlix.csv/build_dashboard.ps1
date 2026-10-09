# Build Netflix Interactive Dashboard HTML file
$dataPath = "data.json"
if (-not (Test-Path $dataPath)) {
    Write-Error "data.json not found!"
    exit 1
}

$jsonData = [System.IO.File]::ReadAllText($dataPath, [System.Text.Encoding]::UTF8)
Write-Output "Loaded JSON data: $($jsonData.Length) chars"

# We will generate the complete standalone dashboard HTML
$htmlTemplate = @'
<!DOCTYPE html>
<html lang="th" class="dark">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Netflix Product Category Analytics & Comparison Studio</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&family=Prompt:wght@300;400;500;600;700&display=swap" rel="stylesheet">
  <style>
    :root {
      --font-sans: 'Plus Jakarta Sans', 'Prompt', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      --bg-main: #0B0F19;
      --bg-card: #111827;
      --bg-card-hover: #1F2937;
      --bg-input: #1E293B;
      --border-color: rgba(255, 255, 255, 0.08);
      --border-hover: rgba(255, 255, 255, 0.16);
      --text-main: #F8FAFC;
      --text-muted: #94A3B8;
      --text-sub: #64748B;
      --accent-red: #E50914;
      --accent-red-hover: #FF1E27;
      --cat-a-color: #E50914;
      --cat-a-bg: rgba(229, 9, 20, 0.12);
      --cat-a-border: rgba(229, 9, 20, 0.35);
      --cat-b-color: #38BDF8;
      --cat-b-bg: rgba(56, 189, 248, 0.12);
      --cat-b-border: rgba(56, 189, 248, 0.35);
      --cat-c-color: #A855F7;
      --cat-c-bg: rgba(168, 85, 247, 0.12);
      --cat-c-border: rgba(168, 85, 247, 0.35);
      --success: #10B981;
      --warning: #F59E0B;
      --radius: 12px;
      --shadow: 0 4px 20px -2px rgba(0, 0, 0, 0.5);
    }

    .light {
      --bg-main: #F8FAFC;
      --bg-card: #FFFFFF;
      --bg-card-hover: #F1F5F9;
      --bg-input: #F1F5F9;
      --border-color: #E2E8F0;
      --border-hover: #CBD5E1;
      --text-main: #0F172A;
      --text-muted: #475569;
      --text-sub: #94A3B8;
      --cat-a-color: #DC2626;
      --cat-a-bg: rgba(220, 38, 38, 0.08);
      --cat-a-border: rgba(220, 38, 38, 0.25);
      --cat-b-color: #0284C7;
      --cat-b-bg: rgba(2, 132, 199, 0.08);
      --cat-b-border: rgba(2, 132, 199, 0.25);
      --shadow: 0 4px 20px -2px rgba(0, 0, 0, 0.06);
    }

    * {
      box-sizing: border-box;
      margin: 0;
      padding: 0;
    }

    body {
      font-family: var(--font-sans);
      background-color: var(--bg-main);
      color: var(--text-main);
      min-height: 100vh;
      line-height: 1.5;
      overflow-x: hidden;
      transition: background-color 0.2s ease, color 0.2s ease;
    }

    /* Scrollbar */
    ::-webkit-scrollbar {
      width: 8px;
      height: 8px;
    }
    ::-webkit-scrollbar-track {
      background: var(--bg-main);
    }
    ::-webkit-scrollbar-thumb {
      background: var(--bg-card-hover);
      border-radius: 4px;
    }
    ::-webkit-scrollbar-thumb:hover {
      background: var(--text-sub);
    }

    /* Layout */
    .app-container {
      max-width: 1440px;
      margin: 0 auto;
      padding: 24px 28px 60px;
    }

    /* Header */
    .header {
      display: flex;
      flex-wrap: wrap;
      justify-content: space-between;
      align-items: center;
      gap: 16px;
      padding-bottom: 20px;
      border-bottom: 1px solid var(--border-color);
      margin-bottom: 24px;
    }

    .brand-section {
      display: flex;
      align-items: center;
      gap: 14px;
    }

    .brand-logo {
      background: linear-gradient(135deg, #E50914 0%, #B20710 100%);
      color: white;
      font-weight: 800;
      font-size: 20px;
      letter-spacing: -0.5px;
      padding: 6px 14px;
      border-radius: 8px;
      box-shadow: 0 4px 12px rgba(229, 9, 20, 0.4);
      display: flex;
      align-items: center;
      justify-content: center;
    }

    .brand-titles h1 {
      font-size: 20px;
      font-weight: 700;
      letter-spacing: -0.3px;
      display: flex;
      align-items: center;
      gap: 8px;
    }

    .brand-titles p {
      font-size: 13px;
      color: var(--text-muted);
    }

    .header-actions {
      display: flex;
      align-items: center;
      gap: 10px;
    }

    .btn {
      display: inline-flex;
      align-items: center;
      justify-content: center;
      gap: 8px;
      padding: 8px 16px;
      border-radius: 8px;
      font-size: 13px;
      font-weight: 600;
      cursor: pointer;
      border: 1px solid var(--border-color);
      background: var(--bg-card);
      color: var(--text-main);
      transition: all 0.2s ease;
      font-family: inherit;
    }

    .btn:hover {
      background: var(--bg-card-hover);
      border-color: var(--border-hover);
      transform: translateY(-1px);
    }

    .btn-primary {
      background: var(--accent-red);
      color: white;
      border-color: var(--accent-red);
    }

    .btn-primary:hover {
      background: var(--accent-red-hover);
      border-color: var(--accent-red-hover);
      box-shadow: 0 4px 14px rgba(229, 9, 20, 0.35);
    }

    .btn-sm {
      padding: 5px 10px;
      font-size: 12px;
      border-radius: 6px;
    }

    /* KPI Summary Strip */
    .kpi-strip {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(170px, 1fr));
      gap: 12px;
      margin-bottom: 24px;
    }

    .kpi-card {
      background: var(--bg-card);
      border: 1px solid var(--border-color);
      border-radius: var(--radius);
      padding: 14px 16px;
      display: flex;
      flex-direction: column;
      gap: 4px;
      position: relative;
      overflow: hidden;
    }

    .kpi-card::before {
      content: '';
      position: absolute;
      top: 0;
      left: 0;
      right: 0;
      height: 2px;
      background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.15), transparent);
    }

    .kpi-label {
      font-size: 11px;
      font-weight: 600;
      text-transform: uppercase;
      letter-spacing: 0.5px;
      color: var(--text-sub);
    }

    .kpi-val {
      font-size: 22px;
      font-weight: 800;
      color: var(--text-main);
      display: flex;
      align-items: baseline;
      gap: 6px;
    }

    .kpi-sub {
      font-size: 11px;
      color: var(--text-muted);
    }

    /* Nav Tabs */
    .tabs-bar {
      display: flex;
      gap: 6px;
      border-bottom: 1px solid var(--border-color);
      margin-bottom: 24px;
      overflow-x: auto;
      padding-bottom: 2px;
    }

    .tab-btn {
      padding: 10px 18px;
      border: none;
      background: transparent;
      color: var(--text-muted);
      font-size: 14px;
      font-weight: 600;
      cursor: pointer;
      border-radius: 8px 8px 0 0;
      display: inline-flex;
      align-items: center;
      gap: 8px;
      transition: all 0.2s ease;
      position: relative;
      white-space: nowrap;
      font-family: inherit;
    }

    .tab-btn:hover {
      color: var(--text-main);
      background: rgba(255, 255, 255, 0.03);
    }

    .tab-btn.active {
      color: var(--text-main);
      background: var(--bg-card);
    }

    .tab-btn.active::after {
      content: '';
      position: absolute;
      bottom: -1px;
      left: 0;
      right: 0;
      height: 2px;
      background: var(--accent-red);
    }

    /* Section Panels */
    .tab-panel {
      display: none;
      animation: fadeIn 0.25s ease-out forwards;
    }

    .tab-panel.active {
      display: block;
    }

    @keyframes fadeIn {
      from { opacity: 0; transform: translateY(4px); }
      to { opacity: 1; transform: translateY(0); }
    }

    /* Selector Card */
    .comparator-header {
      background: var(--bg-card);
      border: 1px solid var(--border-color);
      border-radius: var(--radius);
      padding: 20px;
      margin-bottom: 24px;
      box-shadow: var(--shadow);
    }

    .comparator-selectors {
      display: grid;
      grid-template-columns: 1fr auto 1fr;
      align-items: center;
      gap: 16px;
      margin-bottom: 16px;
    }

    @media (max-width: 768px) {
      .comparator-selectors {
        grid-template-columns: 1fr;
      }
    }

    .cat-select-box {
      border: 1px solid var(--border-color);
      border-radius: 10px;
      padding: 12px 16px;
      background: var(--bg-input);
      position: relative;
      transition: border-color 0.2s;
    }

    .cat-select-box.cat-a-box {
      border-color: var(--cat-a-border);
      background: var(--cat-a-bg);
    }

    .cat-select-box.cat-b-box {
      border-color: var(--cat-b-border);
      background: var(--cat-b-bg);
    }

    .cat-select-box label {
      display: block;
      font-size: 11px;
      font-weight: 700;
      text-transform: uppercase;
      letter-spacing: 0.5px;
      margin-bottom: 6px;
    }

    .cat-a-box label { color: var(--cat-a-color); }
    .cat-b-box label { color: var(--cat-b-color); }

    .select-input {
      width: 100%;
      background: transparent;
      border: none;
      color: var(--text-main);
      font-size: 16px;
      font-weight: 700;
      cursor: pointer;
      outline: none;
      font-family: inherit;
    }

    .select-input option {
      background: #111827;
      color: #F8FAFC;
    }

    .vs-circle {
      width: 44px;
      height: 44px;
      border-radius: 50%;
      background: var(--bg-card);
      border: 2px solid var(--border-color);
      display: flex;
      align-items: center;
      justify-content: center;
      font-weight: 800;
      font-size: 14px;
      color: var(--text-muted);
      cursor: pointer;
      transition: all 0.2s ease;
      margin: 0 auto;
    }

    .vs-circle:hover {
      transform: rotate(180deg) scale(1.1);
      border-color: var(--accent-red);
      color: var(--accent-red);
    }

    /* Battle Presets */
    .preset-bar {
      display: flex;
      align-items: center;
      gap: 8px;
      flex-wrap: wrap;
      padding-top: 14px;
      border-top: 1px solid var(--border-color);
    }

    .preset-title {
      font-size: 12px;
      font-weight: 600;
      color: var(--text-sub);
    }

    .preset-chip {
      padding: 4px 10px;
      border-radius: 100px;
      background: var(--bg-card-hover);
      border: 1px solid var(--border-color);
      color: var(--text-muted);
      font-size: 12px;
      cursor: pointer;
      transition: all 0.15s ease;
    }

    .preset-chip:hover {
      background: var(--border-hover);
      color: var(--text-main);
      border-color: var(--text-sub);
    }

    /* Delta Metrics Grid */
    .delta-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
      gap: 16px;
      margin-bottom: 24px;
    }

    .delta-card {
      background: var(--bg-card);
      border: 1px solid var(--border-color);
      border-radius: var(--radius);
      padding: 16px 18px;
      box-shadow: var(--shadow);
      display: flex;
      flex-direction: column;
      justify-content: space-between;
    }

    .delta-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 12px;
    }

    .delta-title {
      font-size: 12px;
      font-weight: 600;
      color: var(--text-muted);
      text-transform: uppercase;
      letter-spacing: 0.5px;
    }

    .delta-badge {
      font-size: 11px;
      font-weight: 700;
      padding: 2px 8px;
      border-radius: 100px;
    }

    .delta-badge.badge-a {
      background: var(--cat-a-bg);
      color: var(--cat-a-color);
      border: 1px solid var(--cat-a-border);
    }

    .delta-badge.badge-b {
      background: var(--cat-b-bg);
      color: var(--cat-b-color);
      border: 1px solid var(--cat-b-border);
    }

    .delta-badge.badge-tie {
      background: rgba(255, 255, 255, 0.08);
      color: var(--text-muted);
    }

    .delta-values {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 12px;
      margin-bottom: 12px;
    }

    .cat-val-block {
      display: flex;
      flex-direction: column;
    }

    .cat-val-name {
      font-size: 11px;
      font-weight: 600;
      margin-bottom: 2px;
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
    }

    .cat-val-num {
      font-size: 20px;
      font-weight: 800;
    }

    .cat-val-sub {
      font-size: 11px;
      color: var(--text-sub);
    }

    .split-bar {
      height: 6px;
      width: 100%;
      background: rgba(255, 255, 255, 0.08);
      border-radius: 100px;
      overflow: hidden;
      display: flex;
    }

    .split-fill-a {
      background: var(--cat-a-color);
      height: 100%;
      transition: width 0.4s ease;
    }

    .split-fill-b {
      background: var(--cat-b-color);
      height: 100%;
      transition: width 0.4s ease;
    }

    /* Charts Grid */
    .charts-grid {
      display: grid;
      grid-template-columns: repeat(2, 1fr);
      gap: 20px;
      margin-bottom: 24px;
    }

    @media (max-width: 1024px) {
      .charts-grid {
        grid-template-columns: 1fr;
      }
    }

    .chart-card {
      background: var(--bg-card);
      border: 1px solid var(--border-color);
      border-radius: var(--radius);
      padding: 20px;
      box-shadow: var(--shadow);
      display: flex;
      flex-direction: column;
    }

    .chart-card.full-width {
      grid-column: 1 / -1;
    }

    .chart-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 16px;
      flex-wrap: wrap;
      gap: 10px;
    }

    .chart-title-box h3 {
      font-size: 15px;
      font-weight: 700;
      color: var(--text-main);
    }

    .chart-title-box p {
      font-size: 12px;
      color: var(--text-muted);
    }

    .chart-legend {
      display: flex;
      align-items: center;
      gap: 14px;
      font-size: 12px;
      font-weight: 600;
    }

    .legend-item {
      display: flex;
      align-items: center;
      gap: 6px;
    }

    .legend-dot {
      width: 10px;
      height: 10px;
      border-radius: 50%;
    }

    .canvas-container {
      position: relative;
      width: 100%;
      min-height: 280px;
      flex: 1;
    }

    canvas {
      display: block;
      width: 100%;
      height: 100%;
    }

    /* AI Executive Insights Box */
    .insights-box {
      background: linear-gradient(135deg, rgba(229, 9, 20, 0.05) 0%, rgba(56, 189, 248, 0.05) 100%);
      border: 1px solid var(--border-color);
      border-radius: var(--radius);
      padding: 20px 24px;
      margin-bottom: 24px;
    }

    .insights-title {
      font-size: 14px;
      font-weight: 700;
      display: flex;
      align-items: center;
      gap: 8px;
      margin-bottom: 12px;
      color: var(--text-main);
    }

    .insights-list {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
      gap: 12px;
    }

    .insight-item {
      display: flex;
      align-items: flex-start;
      gap: 10px;
      font-size: 13px;
      color: var(--text-muted);
      line-height: 1.5;
    }

    .insight-bullet {
      width: 6px;
      height: 6px;
      border-radius: 50%;
      background: var(--accent-red);
      margin-top: 7px;
      flex-shrink: 0;
    }

    /* Side-by-side titles */
    .side-titles-container {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 20px;
      margin-bottom: 24px;
    }

    @media (max-width: 768px) {
      .side-titles-container {
        grid-template-columns: 1fr;
      }
    }

    .titles-column {
      background: var(--bg-card);
      border: 1px solid var(--border-color);
      border-radius: var(--radius);
      padding: 18px;
      box-shadow: var(--shadow);
    }

    .titles-column-header {
      font-size: 14px;
      font-weight: 700;
      padding-bottom: 12px;
      border-bottom: 1px solid var(--border-color);
      margin-bottom: 12px;
      display: flex;
      justify-content: space-between;
      align-items: center;
    }

    .mini-title-list {
      display: flex;
      flex-direction: column;
      gap: 10px;
      max-height: 420px;
      overflow-y: auto;
      padding-right: 4px;
    }

    .mini-title-card {
      background: var(--bg-input);
      border: 1px solid var(--border-color);
      border-radius: 8px;
      padding: 10px 12px;
      cursor: pointer;
      transition: all 0.15s ease;
    }

    .mini-title-card:hover {
      border-color: var(--border-hover);
      background: var(--bg-card-hover);
      transform: translateX(2px);
    }

    .mini-title-top {
      display: flex;
      justify-content: space-between;
      align-items: flex-start;
      gap: 8px;
      margin-bottom: 4px;
    }

    .mini-title-name {
      font-size: 13px;
      font-weight: 700;
      color: var(--text-main);
    }

    .mini-title-meta {
      display: flex;
      align-items: center;
      gap: 6px;
      font-size: 11px;
      color: var(--text-sub);
    }

    .badge {
      display: inline-block;
      padding: 1px 6px;
      border-radius: 4px;
      font-size: 10px;
      font-weight: 700;
      background: rgba(255, 255, 255, 0.08);
      color: var(--text-muted);
    }

    .badge-movie { background: rgba(229, 9, 20, 0.15); color: #FF4D4D; }
    .badge-tv { background: rgba(56, 189, 248, 0.15); color: #38BDF8; }
    .badge-rating { background: rgba(245, 158, 11, 0.15); color: #FBBF24; }

    /* Table Styles */
    .table-container {
      background: var(--bg-card);
      border: 1px solid var(--border-color);
      border-radius: var(--radius);
      overflow-x: auto;
      box-shadow: var(--shadow);
    }

    .data-table {
      width: 100%;
      border-collapse: collapse;
      font-size: 13px;
      text-align: left;
    }

    .data-table th {
      background: var(--bg-card-hover);
      color: var(--text-sub);
      font-weight: 700;
      font-size: 11px;
      text-transform: uppercase;
      letter-spacing: 0.5px;
      padding: 12px 16px;
      border-bottom: 1px solid var(--border-color);
      cursor: pointer;
      user-select: none;
      white-space: nowrap;
    }

    .data-table th:hover {
      color: var(--text-main);
    }

    .data-table td {
      padding: 12px 16px;
      border-bottom: 1px solid var(--border-color);
      color: var(--text-muted);
      white-space: nowrap;
    }

    .data-table tr:hover td {
      background: rgba(255, 255, 255, 0.02);
      color: var(--text-main);
    }

    .data-table td.fw-bold {
      font-weight: 700;
      color: var(--text-main);
    }

    /* Filters Bar */
    .filter-bar {
      display: flex;
      flex-wrap: wrap;
      gap: 12px;
      align-items: center;
      margin-bottom: 18px;
    }

    .search-input-wrapper {
      position: relative;
      flex: 1;
      min-width: 260px;
    }

    .search-input {
      width: 100%;
      background: var(--bg-card);
      border: 1px solid var(--border-color);
      border-radius: 8px;
      padding: 10px 14px 10px 36px;
      color: var(--text-main);
      font-size: 13px;
      outline: none;
      transition: border-color 0.2s;
      font-family: inherit;
    }

    .search-input:focus {
      border-color: var(--accent-red);
    }

    .search-icon {
      position: absolute;
      left: 12px;
      top: 50%;
      transform: translateY(-50%);
      color: var(--text-sub);
      pointer-events: none;
    }

    .filter-select {
      background: var(--bg-card);
      border: 1px solid var(--border-color);
      border-radius: 8px;
      padding: 10px 14px;
      color: var(--text-main);
      font-size: 13px;
      outline: none;
      font-family: inherit;
      cursor: pointer;
    }

    /* Title Explorer Cards Grid */
    .titles-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
      gap: 16px;
      margin-bottom: 24px;
    }

    .title-card {
      background: var(--bg-card);
      border: 1px solid var(--border-color);
      border-radius: var(--radius);
      padding: 16px;
      display: flex;
      flex-direction: column;
      justify-content: space-between;
      gap: 12px;
      transition: all 0.2s ease;
      cursor: pointer;
      position: relative;
    }

    .title-card:hover {
      border-color: var(--border-hover);
      transform: translateY(-2px);
      box-shadow: 0 8px 24px rgba(0, 0, 0, 0.4);
    }

    .title-card-top {
      display: flex;
      flex-direction: column;
      gap: 6px;
    }

    .title-card-header {
      display: flex;
      justify-content: space-between;
      align-items: flex-start;
      gap: 8px;
    }

    .title-card-title {
      font-size: 15px;
      font-weight: 700;
      color: var(--text-main);
      line-height: 1.3;
    }

    .title-card-desc {
      font-size: 12px;
      color: var(--text-muted);
      display: -webkit-box;
      -webkit-line-clamp: 3;
      -webkit-box-orient: vertical;
      overflow: hidden;
      line-height: 1.5;
    }

    .title-card-tags {
      display: flex;
      flex-wrap: wrap;
      gap: 4px;
    }

    .genre-pill {
      font-size: 11px;
      background: rgba(255, 255, 255, 0.05);
      border: 1px solid var(--border-color);
      color: var(--text-muted);
      padding: 2px 8px;
      border-radius: 4px;
    }

    /* Modal */
    .modal-backdrop {
      position: fixed;
      inset: 0;
      background: rgba(0, 0, 0, 0.75);
      backdrop-filter: blur(4px);
      z-index: 999;
      display: none;
      align-items: center;
      justify-content: center;
      padding: 20px;
    }

    .modal-backdrop.active {
      display: flex;
    }

    .modal-content {
      background: var(--bg-card);
      border: 1px solid var(--border-color);
      border-radius: 16px;
      max-width: 640px;
      width: 100%;
      max-height: 90vh;
      overflow-y: auto;
      padding: 24px;
      position: relative;
      box-shadow: 0 20px 40px rgba(0, 0, 0, 0.6);
      animation: modalSlide 0.2s ease-out;
    }

    @keyframes modalSlide {
      from { transform: scale(0.95); opacity: 0; }
      to { transform: scale(1); opacity: 1; }
    }

    .modal-close {
      position: absolute;
      top: 18px;
      right: 18px;
      width: 32px;
      height: 32px;
      border-radius: 50%;
      background: var(--bg-input);
      border: 1px solid var(--border-color);
      color: var(--text-muted);
      display: flex;
      align-items: center;
      justify-content: center;
      cursor: pointer;
      font-size: 16px;
      transition: all 0.15s;
    }

    .modal-close:hover {
      color: var(--text-main);
      background: var(--bg-card-hover);
    }

    /* Pagination */
    .pagination-bar {
      display: flex;
      justify-content: space-between;
      align-items: center;
      gap: 12px;
      margin-top: 16px;
    }

    .page-info {
      font-size: 13px;
      color: var(--text-sub);
    }
  </style>
</head>
<body>

<div class="app-container">
  <!-- Header -->
  <header class="header">
    <div class="brand-section">
      <div class="brand-logo">N</div>
      <div class="brand-titles">
        <h1>Netflix Category Analytics Studio <span style="font-size:12px; font-weight:500; background:rgba(229,9,20,0.15); color:var(--accent-red); padding:2px 8px; border-radius:100px;">Interactive Pro</span></h1>
        <p>สตูดิโอวิเคราะห์และเปรียบเทียบหมวดหมู่สินค้าและคอนเทนต์ (7,787 รายการ, 42 หมวดหมู่)</p>
      </div>
    </div>
    <div class="header-actions">
      <button class="btn" id="themeToggleBtn" onclick="toggleTheme()" title="สลับโหมด มืด/สว่าง">
        <span id="themeIcon">☀️</span> <span id="themeText">Light</span>
      </button>
      <button class="btn btn-primary" onclick="exportComparisonReport()">
        📥 Export Report (CSV)
      </button>
    </div>
  </header>

  <!-- Global KPI Strip -->
  <section class="kpi-strip">
    <div class="kpi-card">
      <span class="kpi-label">Total Titles (แคตตาล็อกรวม)</span>
      <div class="kpi-val" id="kpiTotalTitles">7,787</div>
      <span class="kpi-sub">100% Netflix Library</span>
    </div>
    <div class="kpi-card">
      <span class="kpi-label">Movies (ภาพยนตร์)</span>
      <div class="kpi-val" id="kpiTotalMovies">5,377</div>
      <span class="kpi-sub">69.05% ของแคตตาล็อก</span>
    </div>
    <div class="kpi-card">
      <span class="kpi-label">TV Shows (ซีรีส์/รายการ)</span>
      <div class="kpi-val" id="kpiTotalTV">2,410</div>
      <span class="kpi-sub">30.95% ของแคตตาล็อก</span>
    </div>
    <div class="kpi-card">
      <span class="kpi-label">Product Categories (หมวดหมู่)</span>
      <div class="kpi-val" id="kpiTotalGenres">42</div>
      <span class="kpi-sub">Genres & Content Types</span>
    </div>
    <div class="kpi-card">
      <span class="kpi-label">Production Countries (ประเทศผู้ผลิต)</span>
      <div class="kpi-val" id="kpiTotalCountries">121</div>
      <span class="kpi-sub">Global Coverage</span>
    </div>
    <div class="kpi-card">
      <span class="kpi-label">Release Span (ช่วงปีที่เผยแพร่)</span>
      <div class="kpi-val">1925 - 2021</div>
      <span class="kpi-sub">96 ปีแห่งคอนเทนต์</span>
    </div>
  </section>

  <!-- Navigation Tabs -->
  <nav class="tabs-bar">
    <button class="tab-btn active" onclick="switchTab('comparator')">
      ⚔️ Category Comparator (เปรียบเทียบหมวดหมู่)
    </button>
    <button class="tab-btn" onclick="switchTab('matrix')">
      📊 Multi-Category Matrix (ตารางจัดอันดับ 42 หมวด)
    </button>
    <button class="tab-btn" onclick="switchTab('explorer')">
      🔎 Product / Title Explorer (ค้นหา 7,787 เรื่อง)
    </button>
    <button class="tab-btn" onclick="switchTab('overview')">
      📈 Catalog Insights (ภาพรวมและสถิติหลัก)
    </button>
  </nav>

  <!-- TAB 1: CATEGORY COMPARATOR -->
  <div id="tab-comparator" class="tab-panel active">
    <!-- Selector Header -->
    <div class="comparator-header">
      <div class="comparator-selectors">
        <!-- Category A -->
        <div class="cat-select-box cat-a-box">
          <label>Category A (หมวดหมู่ที่ 1)</label>
          <select id="selectCatA" class="select-input" onchange="onCategoryChange()">
            <!-- Populated dynamically -->
          </select>
        </div>

        <!-- Swap VS -->
        <button class="vs-circle" onclick="swapCategories()" title="สลับหมวดหมู่ A และ B">
          VS
        </button>

        <!-- Category B -->
        <div class="cat-select-box cat-b-box">
          <label>Category B (หมวดหมู่ที่ 2)</label>
          <select id="selectCatB" class="select-input" onchange="onCategoryChange()">
            <!-- Populated dynamically -->
          </select>
        </div>
      </div>

      <!-- Quick Presets -->
      <div class="preset-bar">
        <span class="preset-title">⚡ Quick Battle Presets (ทางลัดเปรียบเทียบยอดนิยม):</span>
        <button class="preset-chip" onclick="applyPreset('Dramas', 'Comedies')">🎭 Dramas vs Comedies</button>
        <button class="preset-chip" onclick="applyPreset('Action & Adventure', 'Thrillers')">⚔️ Action vs Thrillers</button>
        <button class="preset-chip" onclick="applyPreset('Children & Family Movies', 'Horror Movies')">👶 Family vs Horror</button>
        <button class="preset-chip" onclick="applyPreset('Anime Series', 'Korean TV Shows')">🎌 Anime vs K-Drama</button>
        <button class="preset-chip" onclick="applyPreset('Stand-Up Comedy', 'Music & Musicals')">🎤 Stand-Up vs Music</button>
        <button class="preset-chip" onclick="applyPreset('Crime TV Shows', 'Docuseries')">🕵️ Crime vs Docuseries</button>
        <button class="preset-chip" onclick="applyPreset('Independent Movies', 'International Movies')">🎬 Indie vs International</button>
      </div>
    </div>

    <!-- Live Executive Insights -->
    <div class="insights-box">
      <div class="insights-title">
        <span>💡 Real-time Automated Category Comparison Insights (บทวิเคราะห์สรุปความแตกต่าง)</span>
      </div>
      <div class="insights-list" id="insightsList">
        <!-- Generated dynamically -->
      </div>
    </div>

    <!-- Delta Metrics Grid -->
    <div class="delta-grid" id="deltaGrid">
      <!-- Generated dynamically -->
    </div>

    <!-- Visual Comparison Charts -->
    <div class="charts-grid">
      <!-- Chart 1: Yearly Release Trend -->
      <div class="chart-card full-width">
        <div class="chart-header">
          <div class="chart-title-box">
            <h3>📈 Annual Output & Historical Growth Trend (จำนวนคอนเทนต์ที่ออกฉายรายปี)</h3>
            <p>เปรียบเทียบปริมาณคอนเทนต์ที่สร้างขึ้นในแต่ละปีตั้งแต่ปี 1990 - 2021</p>
          </div>
          <div class="chart-legend" id="yearlyLegend">
            <!-- Legend dynamically updated -->
          </div>
        </div>
        <div class="canvas-container" style="height: 300px;">
          <canvas id="yearlyChart"></canvas>
        </div>
      </div>

      <!-- Chart 2: Content Rating Breakdown -->
      <div class="chart-card">
        <div class="chart-header">
          <div class="chart-title-box">
            <h3>🔞 Content Maturity & Rating Distribution (การกระจายตัวของเรตติ้งผู้ชม)</h3>
            <p>สัดส่วนระดับความเหมาะสมของเนื้อหา (TV-MA, TV-14, PG-13, TV-PG, TV-Y)</p>
          </div>
          <div class="chart-legend" id="ratingLegend"></div>
        </div>
        <div class="canvas-container" style="height: 280px;">
          <canvas id="ratingChart"></canvas>
        </div>
      </div>

      <!-- Chart 3: Top Producing Countries -->
      <div class="chart-card">
        <div class="chart-header">
          <div class="chart-title-box">
            <h3>🌍 Geographic Hubs (Top 6 ประเทศผู้ผลิตหลัก)</h3>
            <p>เปรียบเทียบประเทศต้นกำเนิดของคอนเทนต์ในแต่ละหมวดหมู่</p>
          </div>
          <div class="chart-legend" id="countryLegend"></div>
        </div>
        <div class="canvas-container" style="height: 280px;">
          <canvas id="countryChart"></canvas>
        </div>
      </div>

      <!-- Chart 4: Category DNA Radar -->
      <div class="chart-card">
        <div class="chart-header">
          <div class="chart-title-box">
            <h3>🕸️ Category DNA Multi-Axis Profile (เรดาร์เปรียบเทียบมิติ 6 ด้าน)</h3>
            <p>Volume, Movie Bias, Mature Ratio, Runtime, Global Reach, Recency (0-100)</p>
          </div>
          <div class="chart-legend" id="radarLegend"></div>
        </div>
        <div class="canvas-container" style="height: 280px;">
          <canvas id="radarChart"></canvas>
        </div>
      </div>

      <!-- Chart 5: Duration & Runtime Distribution -->
      <div class="chart-card">
        <div class="chart-header">
          <div class="chart-title-box">
            <h3>⏱️ Duration & Format Distribution (การกระจายตัวของความยาว)</h3>
            <p>ความยาวภาพยนตร์ (นาที) และจำนวนซีซั่นของซีรีส์</p>
          </div>
          <div class="chart-legend" id="durationLegend"></div>
        </div>
        <div class="canvas-container" style="height: 280px;">
          <canvas id="durationChart"></canvas>
        </div>
      </div>
    </div>

    <!-- Side by Side Top Sample Titles -->
    <div class="side-titles-container">
      <div class="titles-column">
        <div class="titles-column-header">
          <span id="colATitle" style="color:var(--cat-a-color);">Category A Sample Titles</span>
          <span class="badge badge-movie" id="colACount">0 Titles</span>
        </div>
        <div class="mini-title-list" id="colAList">
          <!-- Filled dynamically -->
        </div>
      </div>

      <div class="titles-column">
        <div class="titles-column-header">
          <span id="colBTitle" style="color:var(--cat-b-color);">Category B Sample Titles</span>
          <span class="badge badge-tv" id="colBCount">0 Titles</span>
        </div>
        <div class="mini-title-list" id="colBList">
          <!-- Filled dynamically -->
        </div>
      </div>
    </div>
  </div>

  <!-- TAB 2: MULTI-CATEGORY MATRIX -->
  <div id="tab-matrix" class="tab-panel">
    <div class="comparator-header" style="margin-bottom: 20px;">
      <div style="display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:12px;">
        <div>
          <h2 style="font-size:18px; font-weight:700;">📊 Category Benchmarking & Leaderboard (จัดอันดับ 42 หมวดหมู่)</h2>
          <p style="font-size:13px; color:var(--text-muted);">วิเคราะห์ เปรียบเทียบสัดส่วน และจัดอันดับทุก Category ในแคตตาล็อก</p>
        </div>
        <div style="display:flex; gap:8px;">
          <button class="btn btn-sm" onclick="filterMatrixFormat('all')">ทั้งหมด (42)</button>
          <button class="btn btn-sm" onclick="filterMatrixFormat('movie')">🎬 Movie Heavy</button>
          <button class="btn btn-sm" onclick="filterMatrixFormat('tv')">📺 TV Heavy</button>
        </div>
      </div>
    </div>

    <!-- Scatter Matrix Chart -->
    <div class="chart-card full-width" style="margin-bottom: 24px;">
      <div class="chart-header">
        <div class="chart-title-box">
          <h3>🎯 Category Landscape Scatter: Volume vs. Average Runtime vs. Maturity</h3>
          <p>แกน Y = ปริมาณเรื่อง (Volume) | แกน X = ความยาวเฉลี่ย (นาที/ซีซั่น) | ขนาดจุด = สัดส่วนเนื้อหาผู้ใหญ่ (% Mature)</p>
        </div>
      </div>
      <div class="canvas-container" style="height: 340px;">
        <canvas id="matrixScatterChart"></canvas>
      </div>
    </div>

    <!-- Full Table -->
    <div class="table-container">
      <table class="data-table" id="matrixTable">
        <thead>
          <tr>
            <th onclick="sortMatrixTable('rank')">#</th>
            <th onclick="sortMatrixTable('name')">Category (หมวดหมู่) ⬍</th>
            <th onclick="sortMatrixTable('count')">Total Titles ⬍</th>
            <th onclick="sortMatrixTable('share')">Catalog Share ⬍</th>
            <th>Format Mix (% Movie / % TV)</th>
            <th onclick="sortMatrixTable('avgDur')">Avg Duration ⬍</th>
            <th onclick="sortMatrixTable('mature')">Mature Audience % ⬍</th>
            <th onclick="sortMatrixTable('topCountry')">Top Country ⬍</th>
            <th onclick="sortMatrixTable('avgYear')">Avg Year ⬍</th>
            <th>Quick Action</th>
          </tr>
        </thead>
        <tbody id="matrixTableBody">
          <!-- Populated dynamically -->
        </tbody>
      </table>
    </div>
  </div>

  <!-- TAB 3: PRODUCT / TITLE EXPLORER -->
  <div id="tab-explorer" class="tab-panel">
    <!-- Filter Bar -->
    <div class="filter-bar">
      <div class="search-input-wrapper">
        <span class="search-icon">🔍</span>
        <input type="text" id="explorerSearchInput" class="search-input" placeholder="ค้นหาชื่อเรื่อง, นักแสดง, ผู้กำกับ, หรือเรื่องย่อ..." oninput="onExplorerSearch()">
      </div>
      <select id="filterType" class="filter-select" onchange="onExplorerSearch()">
        <option value="all">รูปแบบทั้งหมด (Movies & TV)</option>
        <option value="1">🎬 Movies Only</option>
        <option value="2">📺 TV Shows Only</option>
      </select>
      <select id="filterGenre" class="filter-select" onchange="onExplorerSearch()">
        <option value="all">หมวดหมู่ทั้งหมด (All Genres)</option>
      </select>
      <select id="filterRating" class="filter-select" onchange="onExplorerSearch()">
        <option value="all">เรตติ้งทั้งหมด (All Ratings)</option>
      </select>
      <select id="filterSort" class="filter-select" onchange="onExplorerSearch()">
        <option value="year_desc">ปีที่ฉายล่าสุด (Newest Release)</option>
        <option value="year_asc">ปีที่ฉายเก่าสุด (Oldest Release)</option>
        <option value="title_asc">ชื่อเรื่อง (A-Z)</option>
        <option value="duration_desc">ความยาวมากสุด (Longest)</option>
      </select>
    </div>

    <!-- Explorer Stats -->
    <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:16px;">
      <span class="page-info" id="explorerCountInfo">กำลังแสดง 0 จาก 7,787 เรื่อง</span>
      <div style="display:flex; gap:6px;">
        <button class="btn btn-sm" onclick="setExplorerView('grid')" id="viewGridBtn">🔲 Grid</button>
        <button class="btn btn-sm" onclick="setExplorerView('table')" id="viewTableBtn">📋 List</button>
      </div>
    </div>

    <!-- Grid View -->
    <div class="titles-grid" id="explorerGrid">
      <!-- Populated dynamically -->
    </div>

    <!-- Table View -->
    <div class="table-container" id="explorerTableView" style="display:none; margin-bottom:24px;">
      <table class="data-table">
        <thead>
          <tr>
            <th>Type</th>
            <th>Title</th>
            <th>Release Year</th>
            <th>Rating</th>
            <th>Duration</th>
            <th>Genres</th>
            <th>Country</th>
          </tr>
        </thead>
        <tbody id="explorerTableBody">
          <!-- Populated dynamically -->
        </tbody>
      </table>
    </div>

    <!-- Pagination -->
    <div class="pagination-bar">
      <button class="btn btn-sm" id="prevPageBtn" onclick="changePage(-1)">◀ หน้าก่อนหน้า</button>
      <span class="page-info" id="pageInfo">หน้า 1 / 1</span>
      <button class="btn btn-sm" id="nextPageBtn" onclick="changePage(1)">หน้าถัดไป ▶</button>
    </div>
  </div>

  <!-- TAB 4: CATALOG OVERVIEW -->
  <div id="tab-overview" class="tab-panel">
    <div class="charts-grid">
      <!-- Overview Donut: Movie vs TV -->
      <div class="chart-card">
        <div class="chart-header">
          <div class="chart-title-box">
            <h3>🎬 Content Format Split (สัดส่วนภาพยนตร์ vs ซีรีส์)</h3>
            <p>5,377 Movies (69%) vs 2,410 TV Shows (31%)</p>
          </div>
        </div>
        <div class="canvas-container" style="height: 280px;">
          <canvas id="overviewFormatChart"></canvas>
        </div>
      </div>

      <!-- Overview Top 10 Genres -->
      <div class="chart-card">
        <div class="chart-header">
          <div class="chart-title-box">
            <h3>🏆 Top 10 Largest Product Categories</h3>
            <p>หมวดหมู่ที่มีจำนวนคอนเทนต์สูงสุดในระบบ</p>
          </div>
        </div>
        <div class="canvas-container" style="height: 280px;">
          <canvas id="overviewTopGenresChart"></canvas>
        </div>
      </div>

      <!-- Overview Ratings -->
      <div class="chart-card">
        <div class="chart-header">
          <div class="chart-title-box">
            <h3>📊 Global Audience Maturity Ratings</h3>
            <p>การกระจายตัวของเรตติ้งทั้งหมดใน Netflix</p>
          </div>
        </div>
        <div class="canvas-container" style="height: 280px;">
          <canvas id="overviewRatingsChart"></canvas>
        </div>
      </div>

      <!-- Overview Top 10 Countries -->
      <div class="chart-card">
        <div class="chart-header">
          <div class="chart-title-box">
            <h3>🌐 Top 10 Producing Countries</h3>
            <p>ประเทศผู้สร้างคอนเทนต์สูงสุด</p>
          </div>
        </div>
        <div class="canvas-container" style="height: 280px;">
          <canvas id="overviewCountriesChart"></canvas>
        </div>
      </div>
    </div>
  </div>
</div>

<!-- TITLE DETAIL MODAL -->
<div class="modal-backdrop" id="titleModal" onclick="onModalBackdropClick(event)">
  <div class="modal-content">
    <button class="modal-close" onclick="closeModal()">✕</button>
    <div id="modalBody">
      <!-- Filled dynamically -->
    </div>
  </div>
</div>

<script>
// EMBEDDED DATASET (7,787 items)
// Schema: [type (1=Movie, 2=TV Show), title, director, cast, country, date_added, release_year, rating, duration, genres_str, description, show_id]
const RAW_DATA = @JSON_PLACEHOLDER@;

// APPLICATION STATE
let state = {
  catA: 'Dramas',
  catB: 'Comedies',
  allGenres: [],
  genreStats: {},
  genreIndex: {},
  explorerPage: 1,
  explorerPerPage: 24,
  explorerFiltered: [],
  explorerView: 'grid',
  matrixSortKey: 'count',
  matrixSortAsc: false,
  matrixFilterFormat: 'all',
  theme: 'dark'
};

// INITIALIZATION
document.addEventListener('DOMContentLoaded', () => {
  processRawData();
  populateDropdowns();
  updateComparator();
  renderMatrix();
  initExplorer();
  renderOverviewCharts();
});

// PROCESS RAW DATA
function processRawData() {
  const genreMap = {};

  RAW_DATA.forEach((item, index) => {
    const genres = item[9] ? item[9].split(',').map(g => g.trim()).filter(Boolean) : [];
    genres.forEach(g => {
      if (!genreMap[g]) {
        genreMap[g] = {
          name: g,
          total: 0,
          movies: 0,
          tvShows: 0,
          totalMovieDur: 0,
          movieCountForDur: 0,
          totalTvSeasons: 0,
          tvCountForDur: 0,
          ratings: {},
          countries: {},
          years: {},
          recentCount: 0, // 2016-2021
          matureCount: 0, // TV-MA, R, NC-17, UR
          familyCount: 0, // TV-PG, TV-Y, TV-Y7, G, PG, TV-G
          items: [],
          coOccurring: {}
        };
      }

      const gm = genreMap[g];
      gm.total++;
      gm.items.push(item);

      const type = item[0];
      const year = item[6];
      const rating = item[7] || 'Unrated';
      const dur = item[8];
      const countryStr = item[4] || 'Unknown';

      if (type === 1) {
        gm.movies++;
        if (dur > 0) {
          gm.totalMovieDur += dur;
          gm.movieCountForDur++;
        }
      } else {
        gm.tvShows++;
        if (dur > 0) {
          gm.totalTvSeasons += dur;
          gm.tvCountForDur++;
        }
      }

      // Ratings
      gm.ratings[rating] = (gm.ratings[rating] || 0) + 1;
      if (['TV-MA', 'R', 'NC-17', 'UR'].includes(rating)) {
        gm.matureCount++;
      }
      if (['TV-PG', 'TV-Y', 'TV-Y7', 'TV-G', 'G', 'PG'].includes(rating)) {
        gm.familyCount++;
      }

      // Years
      if (year > 0) {
        gm.years[year] = (gm.years[year] || 0) + 1;
        if (year >= 2016) gm.recentCount++;
      }

      // Countries (split multiple)
      const cList = countryStr.split(',').map(c => c.trim()).filter(Boolean);
      cList.forEach(c => {
        gm.countries[c] = (gm.countries[c] || 0) + 1;
      });

      // Co-occurrence
      genres.forEach(otherG => {
        if (otherG !== g) {
          gm.coOccurring[otherG] = (gm.coOccurring[otherG] || 0) + 1;
        }
      });
    });
  });

  state.genreStats = genreMap;
  state.allGenres = Object.keys(genreMap).sort((a, b) => genreMap[b].total - genreMap[a].total);
}

// POPULATE DROPDOWNS
function populateDropdowns() {
  const selA = document.getElementById('selectCatA');
  const selB = document.getElementById('selectCatB');
  const filterGenre = document.getElementById('filterGenre');
  const filterRating = document.getElementById('filterRating');

  selA.innerHTML = '';
  selB.innerHTML = '';
  filterGenre.innerHTML = '<option value="all">หมวดหมู่ทั้งหมด (All Genres)</option>';

  state.allGenres.forEach(g => {
    const count = state.genreStats[g].total;
    const optA = document.createElement('option');
    optA.value = g;
    optA.textContent = `${g} (${count.toLocaleString()} เรื่อง)`;
    if (g === state.catA) optA.selected = true;
    selA.appendChild(optA);

    const optB = document.createElement('option');
    optB.value = g;
    optB.textContent = `${g} (${count.toLocaleString()} เรื่อง)`;
    if (g === state.catB) optB.selected = true;
    selB.appendChild(optB);

    const optF = document.createElement('option');
    optF.value = g;
    optF.textContent = `${g} (${count})`;
    filterGenre.appendChild(optF);
  });

  // Ratings
  const ratings = ['TV-MA', 'TV-14', 'TV-PG', 'R', 'PG-13', 'TV-Y', 'TV-Y7', 'PG', 'TV-G', 'NR', 'G'];
  filterRating.innerHTML = '<option value="all">เรตติ้งทั้งหมด (All Ratings)</option>';
  ratings.forEach(r => {
    const opt = document.createElement('option');
    opt.value = r;
    opt.textContent = r;
    filterRating.appendChild(opt);
  });
}

// TAB SWITCHING
function switchTab(tabId) {
  document.querySelectorAll('.tab-btn').forEach(btn => btn.classList.remove('active'));
  document.querySelectorAll('.tab-panel').forEach(panel => panel.classList.remove('active'));

  event.currentTarget.classList.add('active');
  const panel = document.getElementById(`tab-${tabId}`);
  if (panel) {
    panel.classList.add('active');
  }

  // Redraw charts if needed
  if (tabId === 'comparator') {
    updateComparatorCharts();
  } else if (tabId === 'matrix') {
    renderMatrixScatter();
  } else if (tabId === 'overview') {
    renderOverviewCharts();
  }
}

// THEME TOGGLE
function toggleTheme() {
  const isDark = document.documentElement.classList.toggle('dark');
  state.theme = isDark ? 'dark' : 'light';
  document.getElementById('themeIcon').textContent = isDark ? '☀️' : '🌙';
  document.getElementById('themeText').textContent = isDark ? 'Light' : 'Dark';
  updateComparatorCharts();
  if (document.getElementById('tab-matrix').classList.contains('active')) {
    renderMatrixScatter();
  }
}

// SWAP CATEGORIES
function swapCategories() {
  const temp = state.catA;
  state.catA = state.catB;
  state.catB = temp;
  document.getElementById('selectCatA').value = state.catA;
  document.getElementById('selectCatB').value = state.catB;
  updateComparator();
}

function onCategoryChange() {
  state.catA = document.getElementById('selectCatA').value;
  state.catB = document.getElementById('selectCatB').value;
  updateComparator();
}

function applyPreset(catA, catB) {
  state.catA = catA;
  state.catB = catB;
  document.getElementById('selectCatA').value = catA;
  document.getElementById('selectCatB').value = catB;
  updateComparator();
}

// UPDATE COMPARATOR
function updateComparator() {
  const statA = state.genreStats[state.catA];
  const statB = state.genreStats[state.catB];
  if (!statA || !statB) return;

  renderExecutiveInsights(statA, statB);
  renderDeltaCards(statA, statB);
  updateComparatorCharts();
  renderSideTitles(statA, statB);
}

// RENDER EXECUTIVE INSIGHTS
function renderExecutiveInsights(a, b) {
  const totalLib = RAW_DATA.length;
  const aShare = ((a.total / totalLib) * 100).toFixed(1);
  const bShare = ((b.total / totalLib) * 100).toFixed(1);
  const aMoviePct = ((a.movies / a.total) * 100).toFixed(0);
  const bMoviePct = ((b.movies / b.total) * 100).toFixed(0);
  const aMaturePct = ((a.matureCount / a.total) * 100).toFixed(0);
  const bMaturePct = ((b.matureCount / b.total) * 100).toFixed(0);

  const topCountryA = Object.entries(a.countries).sort((x, y) => y[1] - x[1])[0] || ['Unknown', 0];
  const topCountryB = Object.entries(b.countries).sort((x, y) => y[1] - x[1])[0] || ['Unknown', 0];

  const insights = [
    `<strong>ขนาดและการครองตลาด:</strong> <strong>${a.name}</strong> มีจำนวน ${a.total.toLocaleString()} เรื่อง (${aShare}% ของแคตตาล็อก) ${a.total > b.total ? 'มากกว่า' : 'น้อยกว่า'} <strong>${b.name}</strong> ซึ่งมี ${b.total.toLocaleString()} เรื่อง (${bShare}%) โดยมีส่วนต่าง ${Math.abs(a.total - b.total).toLocaleString()} เรื่อง`,
    `<strong>สัดส่วนรูปแบบคอนเทนต์:</strong> ${a.name} เน้น ${aMoviePct > 50 ? 'ภาพยนตร์ (Movie)' : 'ซีรีส์ (TV Show)'} (${aMoviePct}% ภาพยนตร์) ในขณะที่ ${b.name} มีสัดส่วนภาพยนตร์อยู่ที่ ${bMoviePct}% (${bMoviePct > 50 ? 'เน้นภาพยนตร์' : 'เน้นซีรีส์'})`,
    `<strong>กลุ่มเป้าหมายและความเหมาะสม (Maturity):</strong> ${aMaturePct > bMaturePct ? `<strong>${a.name}</strong> มีสัดส่วนคอนเทนต์ผู้ใหญ่ (TV-MA/R) สูงกว่าที่ ${aMaturePct}% เทียบกับ ${bMaturePct}% ของ ${b.name}` : `<strong>${b.name}</strong> มีสัดส่วนคอนเทนต์ผู้ใหญ่ (TV-MA/R) สูงกว่าที่ ${bMaturePct}% เทียบกับ ${aMaturePct}% ของ ${a.name}`}`,
    `<strong>ศูนย์กลางการผลิต (Top Origin):</strong> ประเทศผู้ผลิตหลักของ ${a.name} คือ <strong>${topCountryA[0]}</strong> (${topCountryA[1]} เรื่อง) ส่วน ${b.name} ผลิตหลักจาก <strong>${topCountryB[0]}</strong> (${topCountryB[1]} เรื่อง)`
  ];

  const list = document.getElementById('insightsList');
  list.innerHTML = insights.map(i => `
    <div class="insight-item">
      <div class="insight-bullet"></div>
      <div>${i}</div>
    </div>
  `).join('');
}

// RENDER DELTA CARDS
function renderDeltaCards(a, b) {
  const totalLib = RAW_DATA.length;
  const grid = document.getElementById('deltaGrid');

  // 1. Total Titles
  const diffTotal = a.total - b.total;
  const pctDiff = b.total > 0 ? (((a.total - b.total) / b.total) * 100).toFixed(1) : 0;
  const totalBadge = diffTotal > 0 ? `+${diffTotal.toLocaleString()} (+${pctDiff}%)` : `${diffTotal.toLocaleString()} (${pctDiff}%)`;
  const totalBadgeClass = diffTotal > 0 ? 'badge-a' : diffTotal < 0 ? 'badge-b' : 'badge-tie';

  // 2. Format (% Movies)
  const aMoviePct = ((a.movies / a.total) * 100).toFixed(1);
  const bMoviePct = ((b.movies / b.total) * 100).toFixed(1);

  // 3. Avg Duration (Movies)
  const aAvgMovieDur = a.movieCountForDur > 0 ? (a.totalMovieDur / a.movieCountForDur).toFixed(0) : 'N/A';
  const bAvgMovieDur = b.movieCountForDur > 0 ? (b.totalMovieDur / b.movieCountForDur).toFixed(0) : 'N/A';

  // 4. Maturity (% Mature)
  const aMaturePct = ((a.matureCount / a.total) * 100).toFixed(1);
  const bMaturePct = ((b.matureCount / b.total) * 100).toFixed(1);

  // 5. Global Reach (Unique Countries)
  const aCountriesCount = Object.keys(a.countries).length;
  const bCountriesCount = Object.keys(b.countries).length;

  // 6. Modernness (% 2016-2021)
  const aRecentPct = ((a.recentCount / a.total) * 100).toFixed(1);
  const bRecentPct = ((b.recentCount / b.total) * 100).toFixed(1);

  grid.innerHTML = `
    <!-- Card 1: Catalog Volume -->
    <div class="delta-card">
      <div class="delta-header">
        <span class="delta-title">📦 Total Catalog Volume (จำนวนเรื่อง)</span>
        <span class="delta-badge ${totalBadgeClass}">${totalBadge}</span>
      </div>
      <div class="delta-values">
        <div class="cat-val-block">
          <span class="cat-val-name" style="color:var(--cat-a-color);">${a.name}</span>
          <span class="cat-val-num">${a.total.toLocaleString()}</span>
          <span class="cat-val-sub">${((a.total/totalLib)*100).toFixed(1)}% ของแคตตาล็อก</span>
        </div>
        <div class="cat-val-block">
          <span class="cat-val-name" style="color:var(--cat-b-color);">${b.name}</span>
          <span class="cat-val-num">${b.total.toLocaleString()}</span>
          <span class="cat-val-sub">${((b.total/totalLib)*100).toFixed(1)}% ของแคตตาล็อก</span>
        </div>
      </div>
      <div class="split-bar">
        <div class="split-fill-a" style="width: ${(a.total / (a.total + b.total)) * 100}%;"></div>
        <div class="split-fill-b" style="width: ${(b.total / (a.total + b.total)) * 100}%;"></div>
      </div>
    </div>

    <!-- Card 2: Movie vs TV Split -->
    <div class="delta-card">
      <div class="delta-header">
        <span class="delta-title">🎬 Movie Format Ratio (สัดส่วนภาพยนตร์)</span>
        <span class="delta-badge ${aMoviePct > bMoviePct ? 'badge-a' : 'badge-b'}">${aMoviePct > bMoviePct ? a.name : b.name} มี % ภาพยนตร์สูงกว่า</span>
      </div>
      <div class="delta-values">
        <div class="cat-val-block">
          <span class="cat-val-name" style="color:var(--cat-a-color);">${a.name}</span>
          <span class="cat-val-num">${aMoviePct}%</span>
          <span class="cat-val-sub">${a.movies} หนัง / ${a.tvShows} ซีรีส์</span>
        </div>
        <div class="cat-val-block">
          <span class="cat-val-name" style="color:var(--cat-b-color);">${b.name}</span>
          <span class="cat-val-num">${bMoviePct}%</span>
          <span class="cat-val-sub">${b.movies} หนัง / ${b.tvShows} ซีรีส์</span>
        </div>
      </div>
      <div class="split-bar">
        <div class="split-fill-a" style="width: ${aMoviePct}%;"></div>
        <div class="split-fill-b" style="width: ${bMoviePct}%;"></div>
      </div>
    </div>

    <!-- Card 3: Avg Movie Runtime -->
    <div class="delta-card">
      <div class="delta-header">
        <span class="delta-title">⏱️ Average Movie Runtime (ความยาวเฉลี่ย)</span>
        <span class="delta-badge ${Number(aAvgMovieDur) > Number(bAvgMovieDur) ? 'badge-a' : 'badge-b'}">
          ${Math.abs(Number(aAvgMovieDur || 0) - Number(bAvgMovieDur || 0))} นาที ต่างกัน
        </span>
      </div>
      <div class="delta-values">
        <div class="cat-val-block">
          <span class="cat-val-name" style="color:var(--cat-a-color);">${a.name}</span>
          <span class="cat-val-num">${aAvgMovieDur} <span style="font-size:12px;">นาที</span></span>
          <span class="cat-val-sub">ซีรีส์เฉลี่ย ${a.tvCountForDur > 0 ? (a.totalTvSeasons/a.tvCountForDur).toFixed(1) : 0} ซีซั่น</span>
        </div>
        <div class="cat-val-block">
          <span class="cat-val-name" style="color:var(--cat-b-color);">${b.name}</span>
          <span class="cat-val-num">${bAvgMovieDur} <span style="font-size:12px;">นาที</span></span>
          <span class="cat-val-sub">ซีรีส์เฉลี่ย ${b.tvCountForDur > 0 ? (b.totalTvSeasons/b.tvCountForDur).toFixed(1) : 0} ซีซั่น</span>
        </div>
      </div>
      <div class="split-bar">
        <div class="split-fill-a" style="width: ${(Number(aAvgMovieDur)/(Number(aAvgMovieDur)+Number(bAvgMovieDur)))*100}%;"></div>
        <div class="split-fill-b" style="width: ${(Number(bAvgMovieDur)/(Number(aAvgMovieDur)+Number(bAvgMovieDur)))*100}%;"></div>
      </div>
    </div>

    <!-- Card 4: Maturity Index -->
    <div class="delta-card">
      <div class="delta-header">
        <span class="delta-title">🔞 Mature Audience Index (เรตติ้งผู้ใหญ่)</span>
        <span class="delta-badge ${aMaturePct > bMaturePct ? 'badge-a' : 'badge-b'}">${aMaturePct > bMaturePct ? a.name : b.name} เรตผู้ใหญ่สูงกว่า</span>
      </div>
      <div class="delta-values">
        <div class="cat-val-block">
          <span class="cat-val-name" style="color:var(--cat-a-color);">${a.name}</span>
          <span class="cat-val-num">${aMaturePct}%</span>
          <span class="cat-val-sub">${a.matureCount} เรื่อง (TV-MA, R)</span>
        </div>
        <div class="cat-val-block">
          <span class="cat-val-name" style="color:var(--cat-b-color);">${b.name}</span>
          <span class="cat-val-num">${bMaturePct}%</span>
          <span class="cat-val-sub">${b.matureCount} เรื่อง (TV-MA, R)</span>
        </div>
      </div>
      <div class="split-bar">
        <div class="split-fill-a" style="width: ${aMaturePct}%;"></div>
        <div class="split-fill-b" style="width: ${bMaturePct}%;"></div>
      </div>
    </div>

    <!-- Card 5: Geographic Reach -->
    <div class="delta-card">
      <div class="delta-header">
        <span class="delta-title">🌐 Global Footprint (ประเทศผู้ผลิต)</span>
        <span class="delta-badge ${aCountriesCount > bCountriesCount ? 'badge-a' : 'badge-b'}">${aCountriesCount > bCountriesCount ? a.name : b.name} ผลิตในหลายประเทศกว่า</span>
      </div>
      <div class="delta-values">
        <div class="cat-val-block">
          <span class="cat-val-name" style="color:var(--cat-a-color);">${a.name}</span>
          <span class="cat-val-num">${aCountriesCount} <span style="font-size:12px;">ประเทศ</span></span>
          <span class="cat-val-sub">หลัก: ${Object.keys(a.countries)[0] || 'Unknown'}</span>
        </div>
        <div class="cat-val-block">
          <span class="cat-val-name" style="color:var(--cat-b-color);">${b.name}</span>
          <span class="cat-val-num">${bCountriesCount} <span style="font-size:12px;">ประเทศ</span></span>
          <span class="cat-val-sub">หลัก: ${Object.keys(b.countries)[0] || 'Unknown'}</span>
        </div>
      </div>
      <div class="split-bar">
        <div class="split-fill-a" style="width: ${(aCountriesCount/(aCountriesCount+bCountriesCount))*100}%;"></div>
        <div class="split-fill-b" style="width: ${(bCountriesCount/(aCountriesCount+bCountriesCount))*100}%;"></div>
      </div>
    </div>

    <!-- Card 6: Modernness -->
    <div class="delta-card">
      <div class="delta-header">
        <span class="delta-title">⚡ Modern Content Ratio (ปี 2016-2021)</span>
        <span class="delta-badge ${aRecentPct > bRecentPct ? 'badge-a' : 'badge-b'}">${aRecentPct > bRecentPct ? a.name : b.name} มีคอนเทนต์ยุคใหม่มากกว่า</span>
      </div>
      <div class="delta-values">
        <div class="cat-val-block">
          <span class="cat-val-name" style="color:var(--cat-a-color);">${a.name}</span>
          <span class="cat-val-num">${aRecentPct}%</span>
          <span class="cat-val-sub">${a.recentCount} เรื่องตั้งแต่ปี 2016</span>
        </div>
        <div class="cat-val-block">
          <span class="cat-val-name" style="color:var(--cat-b-color);">${b.name}</span>
          <span class="cat-val-num">${bRecentPct}%</span>
          <span class="cat-val-sub">${b.recentCount} เรื่องตั้งแต่ปี 2016</span>
        </div>
      </div>
      <div class="split-bar">
        <div class="split-fill-a" style="width: ${aRecentPct}%;"></div>
        <div class="split-fill-b" style="width: ${bRecentPct}%;"></div>
      </div>
    </div>
  `;
}

// UPDATE COMPARATOR CHARTS
function updateComparatorCharts() {
  const statA = state.genreStats[state.catA];
  const statB = state.genreStats[state.catB];
  if (!statA || !statB) return;

  const colorA = '#E50914';
  const colorB = '#38BDF8';

  // Update legends
  document.getElementById('yearlyLegend').innerHTML = `
    <div class="legend-item"><span class="legend-dot" style="background:${colorA};"></span> ${statA.name}</div>
    <div class="legend-item"><span class="legend-dot" style="background:${colorB};"></span> ${statB.name}</div>
  `;
  document.getElementById('ratingLegend').innerHTML = `
    <div class="legend-item"><span class="legend-dot" style="background:${colorA};"></span> ${statA.name}</div>
    <div class="legend-item"><span class="legend-dot" style="background:${colorB};"></span> ${statB.name}</div>
  `;
  document.getElementById('countryLegend').innerHTML = `
    <div class="legend-item"><span class="legend-dot" style="background:${colorA};"></span> ${statA.name}</div>
    <div class="legend-item"><span class="legend-dot" style="background:${colorB};"></span> ${statB.name}</div>
  `;
  document.getElementById('radarLegend').innerHTML = `
    <div class="legend-item"><span class="legend-dot" style="background:${colorA};"></span> ${statA.name}</div>
    <div class="legend-item"><span class="legend-dot" style="background:${colorB};"></span> ${statB.name}</div>
  `;
  document.getElementById('durationLegend').innerHTML = `
    <div class="legend-item"><span class="legend-dot" style="background:${colorA};"></span> ${statA.name}</div>
    <div class="legend-item"><span class="legend-dot" style="background:${colorB};"></span> ${statB.name}</div>
  `;

  // Draw Chart 1: Yearly Line Chart (1995 - 2021)
  const years = [];
  for (let y = 1995; y <= 2021; y++) years.push(y);
  const dataAYears = years.map(y => statA.years[y] || 0);
  const dataBYears = years.map(y => statB.years[y] || 0);
  drawLineChart('yearlyChart', years, [
    { label: statA.name, data: dataAYears, color: colorA },
    { label: statB.name, data: dataBYears, color: colorB }
  ]);

  // Draw Chart 2: Rating Grouped Bar Chart
  const topRatings = ['TV-MA', 'TV-14', 'TV-PG', 'R', 'PG-13', 'TV-Y', 'TV-Y7', 'PG', 'TV-G'];
  const dataARatings = topRatings.map(r => statA.ratings[r] || 0);
  const dataBRatings = topRatings.map(r => statB.ratings[r] || 0);
  drawGroupedBarChart('ratingChart', topRatings, [
    { label: statA.name, data: dataARatings, color: colorA },
    { label: statB.name, data: dataBRatings, color: colorB }
  ]);

  // Draw Chart 3: Countries Horizontal Bar
  const allTopCountries = new Set([
    ...Object.entries(statA.countries).sort((x,y)=>y[1]-x[1]).slice(0, 5).map(x=>x[0]),
    ...Object.entries(statB.countries).sort((x,y)=>y[1]-x[1]).slice(0, 5).map(x=>x[0])
  ]);
  const countryLabels = Array.from(allTopCountries).slice(0, 6);
  const dataACountry = countryLabels.map(c => statA.countries[c] || 0);
  const dataBCountry = countryLabels.map(c => statB.countries[c] || 0);
  drawHorizontalBarChart('countryChart', countryLabels, [
    { label: statA.name, data: dataACountry, color: colorA },
    { label: statB.name, data: dataBCountry, color: colorB }
  ]);

  // Draw Chart 4: Radar Chart (6 Dimensions)
  const radarLabels = ['Volume', 'Movie %', 'Mature %', 'Avg Runtime', 'Global Reach', 'Modern %'];
  const maxLib = RAW_DATA.length;
  const radarDataA = [
    Math.min(100, (statA.total / 2500) * 100),
    (statA.movies / statA.total) * 100,
    (statA.matureCount / statA.total) * 100,
    Math.min(100, (Number(statA.movieCountForDur > 0 ? statA.totalMovieDur / statA.movieCountForDur : 90) / 150) * 100),
    Math.min(100, (Object.keys(statA.countries).length / 60) * 100),
    (statA.recentCount / statA.total) * 100
  ];
  const radarDataB = [
    Math.min(100, (statB.total / 2500) * 100),
    (statB.movies / statB.total) * 100,
    (statB.matureCount / statB.total) * 100,
    Math.min(100, (Number(statB.movieCountForDur > 0 ? statB.totalMovieDur / statB.movieCountForDur : 90) / 150) * 100),
    Math.min(100, (Object.keys(statB.countries).length / 60) * 100),
    (statB.recentCount / statB.total) * 100
  ];
  drawRadarChart('radarChart', radarLabels, [
    { label: statA.name, data: radarDataA, color: colorA },
    { label: statB.name, data: radarDataB, color: colorB }
  ]);

  // Draw Chart 5: Duration Distribution Buckets
  const durBuckets = ['<60 min', '60-90m', '90-120m', '120m+', 'TV 1 Season', 'TV 2+ Seasons'];
  const calcDurBuckets = (stat) => {
    let b1=0, b2=0, b3=0, b4=0, s1=0, s2=0;
    stat.items.forEach(it => {
      if (it[0] === 1) {
        if (it[8] < 60) b1++;
        else if (it[8] <= 90) b2++;
        else if (it[8] <= 120) b3++;
        else b4++;
      } else {
        if (it[8] <= 1) s1++;
        else s2++;
      }
    });
    return [b1, b2, b3, b4, s1, s2];
  };
  drawGroupedBarChart('durationChart', durBuckets, [
    { label: statA.name, data: calcDurBuckets(statA), color: colorA },
    { label: statB.name, data: calcDurBuckets(statB), color: colorB }
  ]);
}

// RENDER SIDE SAMPLE TITLES
function renderSideTitles(a, b) {
  document.getElementById('colATitle').textContent = a.name;
  document.getElementById('colACount').textContent = `${a.total.toLocaleString()} เรื่อง`;
  document.getElementById('colBTitle').textContent = b.name;
  document.getElementById('colBCount').textContent = `${b.total.toLocaleString()} เรื่อง`;

  const listA = document.getElementById('colAList');
  const listB = document.getElementById('colBList');

  const renderList = (items, container) => {
    container.innerHTML = items.slice(0, 15).map(it => `
      <div class="mini-title-card" onclick="openTitleModal('${it[11]}')">
        <div class="mini-title-top">
          <span class="mini-title-name">${escapeHtml(it[1])}</span>
          <span class="badge ${it[0]===1 ? 'badge-movie' : 'badge-tv'}">${it[0]===1 ? 'Movie' : 'TV Show'}</span>
        </div>
        <div class="mini-title-meta">
          <span>📅 ${it[6]}</span>
          <span class="badge badge-rating">${it[7] || 'NR'}</span>
          <span>⏱️ ${it[8]} ${it[0]===1 ? 'min' : 'Season'}</span>
          <span>🌍 ${escapeHtml(it[4] ? it[4].split(',')[0] : 'Global')}</span>
        </div>
      </div>
    `).join('');
  };

  renderList(a.items, listA);
  renderList(b.items, listB);
}

// RENDER MATRIX TABLE
function renderMatrix() {
  const tbody = document.getElementById('matrixTableBody');
  const totalLib = RAW_DATA.length;

  let list = state.allGenres.map(g => {
    const st = state.genreStats[g];
    const topCountry = Object.entries(st.countries).sort((x, y) => y[1] - x[1])[0] || ['Unknown', 0];
    const avgYear = Object.entries(st.years).reduce((acc, [yr, cnt]) => acc + (Number(yr) * cnt), 0) / (st.total || 1);
    const avgDur = st.movieCountForDur > 0 ? (st.totalMovieDur / st.movieCountForDur) : 0;
    const maturePct = (st.matureCount / st.total) * 100;

    return {
      name: g,
      count: st.total,
      share: (st.total / totalLib) * 100,
      movies: st.movies,
      tvShows: st.tvShows,
      moviePct: (st.movies / st.total) * 100,
      avgDur: avgDur,
      mature: maturePct,
      topCountry: topCountry[0],
      avgYear: Math.round(avgYear)
    };
  });

  // Filter format
  if (state.matrixFilterFormat === 'movie') {
    list = list.filter(x => x.moviePct >= 70);
  } else if (state.matrixFilterFormat === 'tv') {
    list = list.filter(x => x.moviePct <= 30);
  }

  // Sort
  list.sort((a, b) => {
    let vA = a[state.matrixSortKey];
    let vB = b[state.matrixSortKey];
    if (typeof vA === 'string') {
      return state.matrixSortAsc ? vA.localeCompare(vB) : vB.localeCompare(vA);
    }
    return state.matrixSortAsc ? vA - vB : vB - vA;
  });

  tbody.innerHTML = list.map((item, index) => `
    <tr>
      <td>${index + 1}</td>
      <td class="fw-bold">${item.name}</td>
      <td><strong>${item.count.toLocaleString()}</strong></td>
      <td>${item.share.toFixed(1)}%</td>
      <td>
        <div style="display:flex; align-items:center; gap:8px;">
          <div style="width:80px; height:6px; background:rgba(255,255,255,0.08); border-radius:100px; display:flex; overflow:hidden;">
            <div style="width:${item.moviePct}%; background:#E50914;"></div>
            <div style="width:${100-item.moviePct}%; background:#38BDF8;"></div>
          </div>
          <span style="font-size:11px; color:var(--text-sub);">${item.moviePct.toFixed(0)}% M / ${(100-item.moviePct).toFixed(0)}% TV</span>
        </div>
      </td>
      <td>${item.avgDur > 0 ? `${item.avgDur.toFixed(0)} min` : '-'}</td>
      <td>
        <span class="badge ${item.mature > 50 ? 'badge-movie' : 'badge-rating'}">${item.mature.toFixed(0)}%</span>
      </td>
      <td>${item.topCountry}</td>
      <td>${item.avgYear}</td>
      <td>
        <button class="btn btn-sm" onclick="setAndCompare('${escapeJs(item.name)}')">⚔️ Compare</button>
      </td>
    </tr>
  `).join('');
}

function sortMatrixTable(key) {
  if (state.matrixSortKey === key) {
    state.matrixSortAsc = !state.matrixSortAsc;
  } else {
    state.matrixSortKey = key;
    state.matrixSortAsc = false;
  }
  renderMatrix();
}

function filterMatrixFormat(format) {
  state.matrixFilterFormat = format;
  renderMatrix();
}

function setAndCompare(genreName) {
  state.catA = genreName;
  document.getElementById('selectCatA').value = genreName;
  switchTab('comparator');
  document.querySelector('.tabs-bar .tab-btn:first-child').classList.add('active');
  updateComparator();
}

// RENDER MATRIX SCATTER PLOT
function renderMatrixScatter() {
  const canvas = document.getElementById('matrixScatterChart');
  if (!canvas) return;
  const ctx = canvas.getContext('2d');
  const dpr = window.devicePixelRatio || 1;
  const rect = canvas.getBoundingClientRect();
  canvas.width = rect.width * dpr;
  canvas.height = rect.height * dpr;
  ctx.scale(dpr, dpr);

  const w = rect.width;
  const h = rect.height;
  const pad = { top: 20, right: 30, bottom: 40, left: 60 };

  const isDark = document.documentElement.classList.contains('dark');
  const textColor = isDark ? '#94A3B8' : '#475569';
  const gridColor = isDark ? 'rgba(255, 255, 255, 0.06)' : 'rgba(0, 0, 0, 0.06)';

  ctx.clearRect(0, 0, w, h);

  // Data points: x = avg duration (40 - 150 min), y = count (0 - 2500), size = mature %
  const points = state.allGenres.map(g => {
    const st = state.genreStats[g];
    const avgDur = st.movieCountForDur > 0 ? (st.totalMovieDur / st.movieCountForDur) : 60;
    return {
      name: g,
      x: avgDur,
      y: st.total,
      size: Math.max(5, (st.matureCount / st.total) * 18),
      isMovie: (st.movies / st.total) >= 0.5
    };
  });

  const minX = 40, maxX = 140;
  const minY = 0, maxY = 2600;

  // Grid lines
  ctx.strokeStyle = gridColor;
  ctx.lineWidth = 1;
  ctx.fillStyle = textColor;
  ctx.font = '11px sans-serif';

  // Y Grid
  const ySteps = 5;
  for (let i = 0; i <= ySteps; i++) {
    const val = (maxY / ySteps) * i;
    const yPos = h - pad.bottom - (val / maxY) * (h - pad.top - pad.bottom);
    ctx.beginPath();
    ctx.moveTo(pad.left, yPos);
    ctx.lineTo(w - pad.right, yPos);
    ctx.stroke();
    ctx.fillText(val.toLocaleString(), 10, yPos + 4);
  }

  // X Grid
  const xSteps = 5;
  for (let i = 0; i <= xSteps; i++) {
    const val = minX + ((maxX - minX) / xSteps) * i;
    const xPos = pad.left + ((val - minX) / (maxX - minX)) * (w - pad.left - pad.right);
    ctx.beginPath();
    ctx.moveTo(xPos, pad.top);
    ctx.lineTo(xPos, h - pad.bottom);
    ctx.stroke();
    ctx.fillText(`${val.toFixed(0)} min`, xPos - 15, h - pad.bottom + 20);
  }

  // Draw points
  points.forEach(pt => {
    const cx = pad.left + ((pt.x - minX) / (maxX - minX)) * (w - pad.left - pad.right);
    const cy = h - pad.bottom - (pt.y / maxY) * (h - pad.top - pad.bottom);

    ctx.beginPath();
    ctx.arc(cx, cy, pt.size, 0, Math.PI * 2);
    ctx.fillStyle = pt.isMovie ? 'rgba(229, 9, 20, 0.65)' : 'rgba(56, 189, 248, 0.65)';
    ctx.fill();
    ctx.strokeStyle = pt.isMovie ? '#E50914' : '#38BDF8';
    ctx.lineWidth = 1.5;
    ctx.stroke();

    // Label for larger categories
    if (pt.y > 600) {
      ctx.fillStyle = isDark ? '#F8FAFC' : '#0F172A';
      ctx.font = 'bold 11px sans-serif';
      ctx.fillText(pt.name, cx + pt.size + 4, cy + 4);
    }
  });
}

// TITLE EXPLORER
function initExplorer() {
  state.explorerFiltered = RAW_DATA;
  updateExplorer();
}

function onExplorerSearch() {
  const query = document.getElementById('explorerSearchInput').value.toLowerCase().trim();
  const typeFilter = document.getElementById('filterType').value;
  const genreFilter = document.getElementById('filterGenre').value;
  const ratingFilter = document.getElementById('filterRating').value;
  const sortFilter = document.getElementById('filterSort').value;

  let filtered = RAW_DATA.filter(it => {
    // Type filter
    if (typeFilter !== 'all' && it[0] !== Number(typeFilter)) return false;

    // Rating filter
    if (ratingFilter !== 'all' && it[7] !== ratingFilter) return false;

    // Genre filter
    if (genreFilter !== 'all') {
      if (!it[9] || !it[9].includes(genreFilter)) return false;
    }

    // Query search
    if (query) {
      const matchTitle = it[1] && it[1].toLowerCase().includes(query);
      const matchCast = it[3] && it[3].toLowerCase().includes(query);
      const matchDir = it[2] && it[2].toLowerCase().includes(query);
      const matchCountry = it[4] && it[4].toLowerCase().includes(query);
      const matchDesc = it[10] && it[10].toLowerCase().includes(query);
      if (!matchTitle && !matchCast && !matchDir && !matchCountry && !matchDesc) return false;
    }

    return true;
  });

  // Sorting
  filtered.sort((a, b) => {
    if (sortFilter === 'year_desc') return b[6] - a[6];
    if (sortFilter === 'year_asc') return a[6] - b[6];
    if (sortFilter === 'title_asc') return a[1].localeCompare(b[1]);
    if (sortFilter === 'duration_desc') return b[8] - a[8];
    return 0;
  });

  state.explorerFiltered = filtered;
  state.explorerPage = 1;
  updateExplorer();
}

function updateExplorer() {
  const total = state.explorerFiltered.length;
  const totalPages = Math.max(1, Math.ceil(total / state.explorerPerPage));
  if (state.explorerPage > totalPages) state.explorerPage = totalPages;

  document.getElementById('explorerCountInfo').textContent = `กำลังแสดง ${total.toLocaleString()} จาก ${RAW_DATA.length.toLocaleString()} เรื่อง`;
  document.getElementById('pageInfo').textContent = `หน้า ${state.explorerPage} / ${totalPages}`;
  document.getElementById('prevPageBtn').disabled = state.explorerPage <= 1;
  document.getElementById('nextPageBtn').disabled = state.explorerPage >= totalPages;

  const start = (state.explorerPage - 1) * state.explorerPerPage;
  const pageItems = state.explorerFiltered.slice(start, start + state.explorerPerPage);

  const grid = document.getElementById('explorerGrid');
  const tableBody = document.getElementById('explorerTableBody');

  if (state.explorerView === 'grid') {
    grid.style.display = 'grid';
    document.getElementById('explorerTableView').style.display = 'none';
    grid.innerHTML = pageItems.map(it => `
      <div class="title-card" onclick="openTitleModal('${it[11]}')">
        <div class="title-card-top">
          <div class="title-card-header">
            <h4 class="title-card-title">${escapeHtml(it[1])}</h4>
            <span class="badge ${it[0]===1 ? 'badge-movie':'badge-tv'}">${it[0]===1 ? 'Movie':'TV'}</span>
          </div>
          <div class="mini-title-meta">
            <span>📅 ${it[6]}</span>
            <span class="badge badge-rating">${it[7] || 'NR'}</span>
            <span>⏱️ ${it[8]} ${it[0]===1 ? 'min':'Season'}</span>
            <span>🌍 ${escapeHtml(it[4] ? it[4].split(',')[0] : 'Global')}</span>
          </div>
          <p class="title-card-desc">${escapeHtml(it[10] || 'No synopsis available.')}</p>
        </div>
        <div class="title-card-tags">
          ${(it[9] ? it[9].split(',') : []).slice(0, 3).map(g => `<span class="genre-pill">${escapeHtml(g.trim())}</span>`).join('')}
        </div>
      </div>
    `).join('');
  } else {
    grid.style.display = 'none';
    document.getElementById('explorerTableView').style.display = 'block';
    tableBody.innerHTML = pageItems.map(it => `
      <tr onclick="openTitleModal('${it[11]}')" style="cursor:pointer;">
        <td><span class="badge ${it[0]===1 ? 'badge-movie':'badge-tv'}">${it[0]===1 ? 'Movie':'TV'}</span></td>
        <td class="fw-bold">${escapeHtml(it[1])}</td>
        <td>${it[6]}</td>
        <td><span class="badge badge-rating">${it[7] || 'NR'}</span></td>
        <td>${it[8]} ${it[0]===1 ? 'min':'Seasons'}</td>
        <td>${escapeHtml(it[9] || '-')}</td>
        <td>${escapeHtml(it[4] || '-')}</td>
      </tr>
    `).join('');
  }
}

function setExplorerView(view) {
  state.explorerView = view;
  updateExplorer();
}

function changePage(delta) {
  state.explorerPage += delta;
  updateExplorer();
  window.scrollTo({ top: 400, behavior: 'smooth' });
}

// TITLE MODAL
function openTitleModal(showId) {
  const item = RAW_DATA.find(x => x[11] === showId);
  if (!item) return;

  const body = document.getElementById('modalBody');
  const genres = item[9] ? item[9].split(',').map(g => g.trim()) : [];
  const castList = item[3] ? item[3].split(',').map(c => c.trim()) : [];

  body.innerHTML = `
    <div style="display:flex; justify-content:space-between; align-items:flex-start; margin-bottom:12px; padding-right:32px;">
      <h2 style="font-size:20px; font-weight:800; color:var(--text-main);">${escapeHtml(item[1])}</h2>
    </div>
    <div style="display:flex; flex-wrap:wrap; gap:8px; align-items:center; margin-bottom:16px;">
      <span class="badge ${item[0]===1 ? 'badge-movie':'badge-tv'}" style="font-size:12px; padding:4px 10px;">${item[0]===1 ? '🎬 Feature Movie' : '📺 TV Series'}</span>
      <span class="badge badge-rating" style="font-size:12px; padding:4px 10px;">${item[7] || 'NR'}</span>
      <span style="font-size:13px; font-weight:600; color:var(--text-main);">📅 Released ${item[6]}</span>
      <span style="font-size:13px; font-weight:600; color:var(--text-main);">⏱️ ${item[8]} ${item[0]===1 ? 'minutes' : 'Seasons'}</span>
      <span style="font-size:13px; color:var(--text-sub);">📥 Added: ${escapeHtml(item[5] || '-')}</span>
    </div>

    <div style="margin-bottom:16px;">
      <h4 style="font-size:12px; font-weight:700; color:var(--text-sub); text-transform:uppercase; margin-bottom:6px;">Synopsis (เรื่องย่อ)</h4>
      <p style="font-size:14px; line-height:1.6; color:var(--text-muted);">${escapeHtml(item[10] || 'No description available.')}</p>
    </div>

    <div style="display:grid; grid-template-columns:1fr 1fr; gap:16px; margin-bottom:16px;">
      <div>
        <h4 style="font-size:12px; font-weight:700; color:var(--text-sub); text-transform:uppercase; margin-bottom:4px;">Director (ผู้กำกับ)</h4>
        <p style="font-size:13px; color:var(--text-main);">${escapeHtml(item[2] || 'Not specified')}</p>
      </div>
      <div>
        <h4 style="font-size:12px; font-weight:700; color:var(--text-sub); text-transform:uppercase; margin-bottom:4px;">Country of Origin</h4>
        <p style="font-size:13px; color:var(--text-main);">${escapeHtml(item[4] || 'Not specified')}</p>
      </div>
    </div>

    <div style="margin-bottom:16px;">
      <h4 style="font-size:12px; font-weight:700; color:var(--text-sub); text-transform:uppercase; margin-bottom:6px;">Cast Members (นักแสดง)</h4>
      <div style="display:flex; flex-wrap:wrap; gap:6px;">
        ${castList.length > 0 ? castList.map(c => `<span class="genre-pill" style="font-size:12px;">👤 ${escapeHtml(c)}</span>`).join('') : '<span style="font-size:13px; color:var(--text-sub);">No cast info</span>'}
      </div>
    </div>

    <div>
      <h4 style="font-size:12px; font-weight:700; color:var(--text-sub); text-transform:uppercase; margin-bottom:6px;">Categories (หมวดหมู่สินค้า)</h4>
      <div style="display:flex; flex-wrap:wrap; gap:8px;">
        ${genres.map(g => `
          <button class="btn btn-sm" onclick="setAndCompare('${escapeJs(g)}'); closeModal();">
            ⚔️ Compare "${escapeHtml(g)}"
          </button>
        `).join('')}
      </div>
    </div>
  `;

  document.getElementById('titleModal').classList.add('active');
}

function closeModal() {
  document.getElementById('titleModal').classList.remove('active');
}

function onModalBackdropClick(e) {
  if (e.target === document.getElementById('titleModal')) {
    closeModal();
  }
}

// RENDER OVERVIEW CHARTS
function renderOverviewCharts() {
  // 1. Format split donut
  drawDonutChart('overviewFormatChart', [
    { label: 'Movies (ภาพยนตร์)', value: 5377, color: '#E50914' },
    { label: 'TV Shows (ซีรีส์)', value: 2410, color: '#38BDF8' }
  ]);

  // 2. Top 10 Genres
  const top10 = state.allGenres.slice(0, 10);
  const top10Counts = top10.map(g => state.genreStats[g].total);
  drawHorizontalBarChart('overviewTopGenresChart', top10, [
    { label: 'Total Titles', data: top10Counts, color: '#E50914' }
  ]);

  // 3. Top Ratings
  const topRatings = ['TV-MA', 'TV-14', 'TV-PG', 'R', 'PG-13', 'TV-Y', 'TV-Y7', 'PG', 'TV-G'];
  const ratingCounts = topRatings.map(r => RAW_DATA.filter(x => x[7] === r).length);
  drawGroupedBarChart('overviewRatingsChart', topRatings, [
    { label: 'Total Titles', data: ratingCounts, color: '#F59E0B' }
  ]);

  // 4. Top Countries
  const countryCounts = {};
  RAW_DATA.forEach(it => {
    if (it[4]) {
      it[4].split(',').forEach(c => {
        const tr = c.trim();
        if (tr) countryCounts[tr] = (countryCounts[tr] || 0) + 1;
      });
    }
  });
  const topCountries = Object.entries(countryCounts).sort((a,b)=>b[1]-a[1]).slice(0, 10);
  drawHorizontalBarChart('overviewCountriesChart', topCountries.map(x=>x[0]), [
    { label: 'Titles', data: topCountries.map(x=>x[1]), color: '#10B981' }
  ]);
}

// EXPORT COMPARISON REPORT
function exportComparisonReport() {
  const statA = state.genreStats[state.catA];
  const statB = state.genreStats[state.catB];
  if (!statA || !statB) return;

  const rows = [
    ['Metric', statA.name, statB.name, 'Delta / Difference'],
    ['Total Titles', statA.total, statB.total, statA.total - statB.total],
    ['Movies Count', statA.movies, statB.movies, statA.movies - statB.movies],
    ['TV Shows Count', statA.tvShows, statB.tvShows, statA.tvShows - statB.tvShows],
    ['Movie Ratio (%)', ((statA.movies/statA.total)*100).toFixed(1), ((statB.movies/statB.total)*100).toFixed(1), (((statA.movies/statA.total)-(statB.movies/statB.total))*100).toFixed(1)],
    ['Avg Movie Duration (min)', statA.movieCountForDur>0 ? (statA.totalMovieDur/statA.movieCountForDur).toFixed(1):0, statB.movieCountForDur>0 ? (statB.totalMovieDur/statB.movieCountForDur).toFixed(1):0, ''],
    ['Mature Rating % (TV-MA/R)', ((statA.matureCount/statA.total)*100).toFixed(1), ((statB.matureCount/statB.total)*100).toFixed(1), ''],
    ['Unique Producing Countries', Object.keys(statA.countries).length, Object.keys(statB.countries).length, ''],
    ['Modern Titles (2016+)', statA.recentCount, statB.recentCount, '']
  ];

  const csvContent = 'data:text/csv;charset=utf-8,' + rows.map(e => e.map(cell => `"${cell}"`).join(',')).join('\n');
  const encodedUri = encodeURI(csvContent);
  const link = document.createElement('a');
  link.setAttribute('href', encodedUri);
  link.setAttribute('download', `netflix_category_comparison_${state.catA}_vs_${state.catB}.csv`);
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
}

// UTILITY CANVAS CHART FUNCTIONS (High performance, pure JS canvas)
function drawLineChart(canvasId, labels, datasets) {
  const canvas = document.getElementById(canvasId);
  if (!canvas) return;
  const ctx = canvas.getContext('2d');
  const dpr = window.devicePixelRatio || 1;
  const rect = canvas.getBoundingClientRect();
  canvas.width = rect.width * dpr;
  canvas.height = rect.height * dpr;
  ctx.scale(dpr, dpr);

  const w = rect.width;
  const h = rect.height;
  const pad = { top: 20, right: 20, bottom: 30, left: 45 };

  const isDark = document.documentElement.classList.contains('dark');
  const textColor = isDark ? '#94A3B8' : '#475569';
  const gridColor = isDark ? 'rgba(255, 255, 255, 0.06)' : 'rgba(0, 0, 0, 0.06)';

  ctx.clearRect(0, 0, w, h);

  let maxVal = Math.max(...datasets.flatMap(d => d.data), 10);
  maxVal = Math.ceil(maxVal * 1.1);

  // Y Grid
  const ySteps = 4;
  ctx.strokeStyle = gridColor;
  ctx.lineWidth = 1;
  ctx.fillStyle = textColor;
  ctx.font = '11px sans-serif';

  for (let i = 0; i <= ySteps; i++) {
    const val = Math.round((maxVal / ySteps) * i);
    const yPos = h - pad.bottom - (val / maxVal) * (h - pad.top - pad.bottom);
    ctx.beginPath();
    ctx.moveTo(pad.left, yPos);
    ctx.lineTo(w - pad.right, yPos);
    ctx.stroke();
    ctx.fillText(val.toString(), 10, yPos + 4);
  }

  // X Labels (sample every few)
  const stepX = (w - pad.left - pad.right) / (labels.length - 1);
  labels.forEach((lbl, idx) => {
    if (idx % 3 === 0 || idx === labels.length - 1) {
      const xPos = pad.left + idx * stepX;
      ctx.fillText(lbl.toString(), xPos - 12, h - pad.bottom + 18);
    }
  });

  // Lines
  datasets.forEach(ds => {
    ctx.strokeStyle = ds.color;
    ctx.lineWidth = 2.5;
    ctx.beginPath();

    ds.data.forEach((val, idx) => {
      const xPos = pad.left + idx * stepX;
      const yPos = h - pad.bottom - (val / maxVal) * (h - pad.top - pad.bottom);
      if (idx === 0) ctx.moveTo(xPos, yPos);
      else ctx.lineTo(xPos, yPos);
    });
    ctx.stroke();

    // Area Gradient
    const gradient = ctx.createLinearGradient(0, pad.top, 0, h - pad.bottom);
    gradient.addColorStop(0, hexToRgba(ds.color, 0.25));
    gradient.addColorStop(1, hexToRgba(ds.color, 0.0));

    ctx.lineTo(pad.left + (labels.length - 1) * stepX, h - pad.bottom);
    ctx.lineTo(pad.left, h - pad.bottom);
    ctx.closePath();
    ctx.fillStyle = gradient;
    ctx.fill();

    // Dots
    ds.data.forEach((val, idx) => {
      if (idx % 2 === 0 || idx === labels.length - 1) {
        const xPos = pad.left + idx * stepX;
        const yPos = h - pad.bottom - (val / maxVal) * (h - pad.top - pad.bottom);
        ctx.beginPath();
        ctx.arc(xPos, yPos, 3.5, 0, Math.PI * 2);
        ctx.fillStyle = ds.color;
        ctx.fill();
      }
    });
  });
}

function drawGroupedBarChart(canvasId, labels, datasets) {
  const canvas = document.getElementById(canvasId);
  if (!canvas) return;
  const ctx = canvas.getContext('2d');
  const dpr = window.devicePixelRatio || 1;
  const rect = canvas.getBoundingClientRect();
  canvas.width = rect.width * dpr;
  canvas.height = rect.height * dpr;
  ctx.scale(dpr, dpr);

  const w = rect.width;
  const h = rect.height;
  const pad = { top: 20, right: 20, bottom: 35, left: 45 };

  const isDark = document.documentElement.classList.contains('dark');
  const textColor = isDark ? '#94A3B8' : '#475569';
  const gridColor = isDark ? 'rgba(255, 255, 255, 0.06)' : 'rgba(0, 0, 0, 0.06)';

  ctx.clearRect(0, 0, w, h);

  let maxVal = Math.max(...datasets.flatMap(d => d.data), 10);
  maxVal = Math.ceil(maxVal * 1.15);

  // Y Grid
  const ySteps = 4;
  ctx.strokeStyle = gridColor;
  ctx.lineWidth = 1;
  ctx.fillStyle = textColor;
  ctx.font = '11px sans-serif';

  for (let i = 0; i <= ySteps; i++) {
    const val = Math.round((maxVal / ySteps) * i);
    const yPos = h - pad.bottom - (val / maxVal) * (h - pad.top - pad.bottom);
    ctx.beginPath();
    ctx.moveTo(pad.left, yPos);
    ctx.lineTo(w - pad.right, yPos);
    ctx.stroke();
    ctx.fillText(val.toString(), 10, yPos + 4);
  }

  // Bars
  const groupWidth = (w - pad.left - pad.right) / labels.length;
  const numBars = datasets.length;
  const barWidth = Math.max(4, (groupWidth * 0.7) / numBars);

  labels.forEach((lbl, groupIdx) => {
    const groupX = pad.left + groupIdx * groupWidth + (groupWidth * 0.15);

    datasets.forEach((ds, dsIdx) => {
      const val = ds.data[groupIdx] || 0;
      const barHeight = (val / maxVal) * (h - pad.top - pad.bottom);
      const xPos = groupX + dsIdx * barWidth;
      const yPos = h - pad.bottom - barHeight;

      ctx.fillStyle = ds.color;
      ctx.beginPath();
      ctx.roundRect(xPos, yPos, barWidth - 2, barHeight, [3, 3, 0, 0]);
      ctx.fill();
    });

    // Label
    ctx.fillStyle = textColor;
    ctx.font = '11px sans-serif';
    ctx.fillText(lbl, groupX, h - pad.bottom + 16);
  });
}

function drawHorizontalBarChart(canvasId, labels, datasets) {
  const canvas = document.getElementById(canvasId);
  if (!canvas) return;
  const ctx = canvas.getContext('2d');
  const dpr = window.devicePixelRatio || 1;
  const rect = canvas.getBoundingClientRect();
  canvas.width = rect.width * dpr;
  canvas.height = rect.height * dpr;
  ctx.scale(dpr, dpr);

  const w = rect.width;
  const h = rect.height;
  const pad = { top: 10, right: 30, bottom: 20, left: 110 };

  const isDark = document.documentElement.classList.contains('dark');
  const textColor = isDark ? '#94A3B8' : '#475569';
  const gridColor = isDark ? 'rgba(255, 255, 255, 0.06)' : 'rgba(0, 0, 0, 0.06)';

  ctx.clearRect(0, 0, w, h);

  let maxVal = Math.max(...datasets.flatMap(d => d.data), 10);
  maxVal = Math.ceil(maxVal * 1.15);

  const rowHeight = (h - pad.top - pad.bottom) / labels.length;
  const numBars = datasets.length;
  const barHeight = Math.max(4, (rowHeight * 0.7) / numBars);

  labels.forEach((lbl, rowIdx) => {
    const rowY = pad.top + rowIdx * rowHeight + (rowHeight * 0.15);

    // Label
    ctx.fillStyle = textColor;
    ctx.font = '11px sans-serif';
    ctx.fillText(truncateStr(lbl, 14), 10, rowY + rowHeight * 0.4);

    datasets.forEach((ds, dsIdx) => {
      const val = ds.data[rowIdx] || 0;
      const barLen = (val / maxVal) * (w - pad.left - pad.right);
      const yPos = rowY + dsIdx * barHeight;

      ctx.fillStyle = ds.color;
      ctx.beginPath();
      ctx.roundRect(pad.left, yPos, barLen, barHeight - 2, [0, 3, 3, 0]);
      ctx.fill();

      // Value label
      if (barLen > 25) {
        ctx.fillStyle = '#FFFFFF';
        ctx.font = '10px sans-serif';
        ctx.fillText(val.toString(), pad.left + barLen - 20, yPos + barHeight - 4);
      }
    });
  });
}

function drawRadarChart(canvasId, labels, datasets) {
  const canvas = document.getElementById(canvasId);
  if (!canvas) return;
  const ctx = canvas.getContext('2d');
  const dpr = window.devicePixelRatio || 1;
  const rect = canvas.getBoundingClientRect();
  canvas.width = rect.width * dpr;
  canvas.height = rect.height * dpr;
  ctx.scale(dpr, dpr);

  const w = rect.width;
  const h = rect.height;
  const cx = w / 2;
  const cy = h / 2 + 5;
  const radius = Math.min(cx, cy) - 35;

  const isDark = document.documentElement.classList.contains('dark');
  const textColor = isDark ? '#94A3B8' : '#475569';
  const gridColor = isDark ? 'rgba(255, 255, 255, 0.08)' : 'rgba(0, 0, 0, 0.08)';

  ctx.clearRect(0, 0, w, h);

  const numAxes = labels.length;
  const angleStep = (Math.PI * 2) / numAxes;

  // Concentric Rings
  const rings = 4;
  for (let r = 1; r <= rings; r++) {
    const ringRadius = (radius / rings) * r;
    ctx.beginPath();
    for (let i = 0; i < numAxes; i++) {
      const angle = i * angleStep - Math.PI / 2;
      const x = cx + ringRadius * Math.cos(angle);
      const y = cy + ringRadius * Math.sin(angle);
      if (i === 0) ctx.moveTo(x, y);
      else ctx.lineTo(x, y);
    }
    ctx.closePath();
    ctx.strokeStyle = gridColor;
    ctx.stroke();
  }

  // Axis lines & labels
  labels.forEach((lbl, i) => {
    const angle = i * angleStep - Math.PI / 2;
    const x = cx + radius * Math.cos(angle);
    const y = cy + radius * Math.sin(angle);

    ctx.beginPath();
    ctx.moveTo(cx, cy);
    ctx.lineTo(x, y);
    ctx.strokeStyle = gridColor;
    ctx.stroke();

    // Text
    const tx = cx + (radius + 18) * Math.cos(angle);
    const ty = cy + (radius + 18) * Math.sin(angle);
    ctx.fillStyle = textColor;
    ctx.font = '11px sans-serif';
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';
    ctx.fillText(lbl, tx, ty);
  });

  // Polygons
  datasets.forEach(ds => {
    ctx.beginPath();
    ds.data.forEach((val, i) => {
      const r = (val / 100) * radius;
      const angle = i * angleStep - Math.PI / 2;
      const x = cx + r * Math.cos(angle);
      const y = cy + r * Math.sin(angle);
      if (i === 0) ctx.moveTo(x, y);
      else ctx.lineTo(x, y);
    });
    ctx.closePath();

    ctx.fillStyle = hexToRgba(ds.color, 0.25);
    ctx.fill();
    ctx.strokeStyle = ds.color;
    ctx.lineWidth = 2;
    ctx.stroke();

    // Dots
    ds.data.forEach((val, i) => {
      const r = (val / 100) * radius;
      const angle = i * angleStep - Math.PI / 2;
      const x = cx + r * Math.cos(angle);
      const y = cy + r * Math.sin(angle);
      ctx.beginPath();
      ctx.arc(x, y, 3, 0, Math.PI * 2);
      ctx.fillStyle = ds.color;
      ctx.fill();
    });
  });
}

function drawDonutChart(canvasId, slices) {
  const canvas = document.getElementById(canvasId);
  if (!canvas) return;
  const ctx = canvas.getContext('2d');
  const dpr = window.devicePixelRatio || 1;
  const rect = canvas.getBoundingClientRect();
  canvas.width = rect.width * dpr;
  canvas.height = rect.height * dpr;
  ctx.scale(dpr, dpr);

  const w = rect.width;
  const h = rect.height;
  const cx = w / 2;
  const cy = h / 2;
  const radius = Math.min(cx, cy) - 20;
  const innerRadius = radius * 0.58;

  ctx.clearRect(0, 0, w, h);

  const total = slices.reduce((a, b) => a + b.value, 0);
  let startAngle = -Math.PI / 2;

  slices.forEach(slice => {
    const sliceAngle = (slice.value / total) * Math.PI * 2;
    ctx.beginPath();
    ctx.arc(cx, cy, radius, startAngle, startAngle + sliceAngle);
    ctx.arc(cx, cy, innerRadius, startAngle + sliceAngle, startAngle, true);
    ctx.closePath();
    ctx.fillStyle = slice.color;
    ctx.fill();
    startAngle += sliceAngle;
  });

  // Center Text
  const isDark = document.documentElement.classList.contains('dark');
  ctx.fillStyle = isDark ? '#F8FAFC' : '#0F172A';
  ctx.font = 'bold 16px sans-serif';
  ctx.textAlign = 'center';
  ctx.textBaseline = 'middle';
  ctx.fillText(total.toLocaleString(), cx, cy - 8);
  ctx.font = '11px sans-serif';
  ctx.fillStyle = isDark ? '#94A3B8' : '#64748B';
  ctx.fillText('Total Titles', cx, cy + 12);
}

// HELPERS
function hexToRgba(hex, alpha) {
  hex = hex.replace('#', '');
  if (hex.length === 3) hex = hex.split('').map(c => c+c).join('');
  const r = parseInt(hex.substring(0, 2), 16);
  const g = parseInt(hex.substring(2, 4), 16);
  const b = parseInt(hex.substring(4, 6), 16);
  return `rgba(${r}, ${g}, ${b}, ${alpha})`;
}

function truncateStr(str, len) {
  if (!str) return '';
  return str.length > len ? str.substring(0, len) + '...' : str;
}

function escapeHtml(str) {
  if (!str) return '';
  return str.toString()
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;');
}

function escapeJs(str) {
  if (!str) return '';
  return str.toString().replace(/'/g, "\\'").replace(/"/g, '\\"');
}
</script>
</body>
</html>
'@

$finalHtml = $htmlTemplate.Replace("@JSON_PLACEHOLDER@", $jsonData)

# Output paths
$workspaceTarget = "c:\Users\Earn Pannara\Downloads\NetFlix.csv\index.html"
$workspaceTarget2 = "c:\Users\Earn Pannara\Downloads\NetFlix.csv\netflix_category_dashboard.html"
$artifactTarget = "C:\Users\Earn Pannara\.gemini\antigravity\brain\16bb9bf8-f31c-444f-9104-694cd66b0d1b\netflix_category_dashboard.html"

[System.IO.File]::WriteAllText($workspaceTarget, $finalHtml, [System.Text.Encoding]::UTF8)
[System.IO.File]::WriteAllText($workspaceTarget2, $finalHtml, [System.Text.Encoding]::UTF8)
[System.IO.File]::WriteAllText($artifactTarget, $finalHtml, [System.Text.Encoding]::UTF8)

Write-Output "Successfully generated Interactive Dashboard at:"
Write-Output "1. $workspaceTarget"
Write-Output "2. $workspaceTarget2"
Write-Output "3. $artifactTarget"
Write-Output "File size: $([math]::Round($finalHtml.Length / 1MB, 2)) MB"

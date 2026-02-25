# 🏀 NBA Player Performance & MVP Analysis (SQL)

Fans are always debating who the GOAT is — this project brings **data into the conversation**.  
Using multi-season NBA player statistics, this analysis explores player performance, era-based trends, team impact, and identifies **data-driven MVPs** using statistical weighting.

---

## 📌 Project Objectives

This project answers the following questions:

1. Which players lead their seasons in **scoring, rebounding, and playmaking** — and how efficient are they?
2. How do players from different **eras (1990s–2020s)** compare in size, style, and performance?
3. Which **teams and player types** consistently produce top performers?
4. Based on data, **who deserves the MVP crown**, and how does it compare to the official NBA MVP?
5. Can we build a **Dream Starting 5** using historical player performance?

---

## 🛠 Tech Stack

- **SQL (MySQL)** – core analysis and transformations  
- **Excel** – validation and exploratory checks  

---

## 📂 Dataset

- **Table:** `nba_player_stats.all_seasons`
- Covers multiple NBA seasons with:
  - Player statistics (PTS, REB, AST)
  - Advanced metrics (TS%, Usage %, Net Rating)
  - Draft details, height, weight, team info

---

## 🧹 Data Cleaning & Preparation

The following steps were performed to ensure clean and reliable analysis:

- Renamed unknown columns for clarity  
- Trimmed and standardized text fields  
- Converted draft-related fields from strings (`Undrafted`) to numeric values  
- Extracted starting year from season format (`1996-97 → 1996`)  
- Rounded percentage and numeric metrics for consistency  
- Checked for duplicate player records  

---

## 📊 Analysis Breakdown

---

### 1️⃣ Player Performance Analysis

**Questions answered:**
- Who leads each season in points, rebounds, and assists?
- Do high-usage scorers sacrifice efficiency?
- Which players show the biggest improvement year-over-year?

**Key techniques used:**
- Window functions (`RANK()`, `LAG()`)
- Season-wise ranking
- Efficiency vs usage comparisons
- Improvement calculations across seasons

---

### 2️⃣ Era & Team Comparisons

**Era Analysis (1990s–2020s):**
- Compared average **player height and weight**
- Observed physical and play-style evolution across decades

**Team Impact Analysis:**
- Ranked teams by frequency of producing **top 10 performers**
- Considered scoring, rebounding, playmaking, efficiency, and impact metrics

---

### 3️⃣ Rookie vs Veteran Analysis

**Approach:**
- Identified each player’s rookie season
- Calculated experience per season
- Classified players as:
  - Rookie (0 years)
  - Mid-level (1–3 years)
  - Veteran (4+ years)

**Insight focus:**
- How experience level impacts contribution and performance consistency

---

## 🏆 MVP & Dream Team Analysis

### MVP Selection (Data-Driven)

A custom MVP index was created using weighted metrics:

- **40%** Scoring (Points per Game)  
- **30%** Playmaking & Rebounding  
- **30%** Efficiency (TS%)  

Players were ranked season-wise using this index to identify the **statistical MVP**, which was then compared with the **official NBA MVP** for validation.

---

### 🌟 Dream Starting 5

Built an all-time **Dream Starting 5**:
- PG, SG, SF, PF, C  
- Selected using aggregated performance, efficiency, and impact metrics across all seasons

---

## 🔍 Key SQL Concepts Demonstrated

- Data cleaning and transformation
- Window functions (`RANK`, `LAG`)
- CTEs for multi-step analysis
- Conditional logic (`CASE WHEN`)
- Aggregations and performance indexing
- Business-driven analytical thinking

---

## 📈 Key Insights

- High-usage scorers do not always maintain high efficiency
- Player size and style have evolved significantly across eras
- Certain teams consistently develop elite performers
- Data-driven MVP picks often align closely — but not always — with official selections

---


Aspiring Data Analyst  
**Skills:** SQL • Python • Excel • Power BI  

🔗 LinkedIn: https://linkedin.com/in/l-surmala-00293b66  
🔗 GitHub: https://github.com/Surmala

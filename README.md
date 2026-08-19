# social-media-SQL-analytics
Social media database schema + advanced SQL practice (subqueries, window functions) in MySQL.

A relational database modeling a social media platform (Instagram-style), built to practice advanced SQL: multi-table joins, correlated subqueries, and window functions (LEAD, NTILE, DENSE_RANK, FIRST_VALUE, CUME_DIST).

Queries
File	Focus	Count
01_subqueries_joins.sql	Correlated subqueries & joins	5
02_window_functions.sql	LEAD, NTILE, DENSE_RANK, FIRST_VALUE, CUME_DIST	5
03_business_questions.sql	Business/analytics questions	8
04_practice_queries.sql	General practice + CTEs	10

Each query has an inline comment explaining its purpose and technique.

Project structure
social-media-sql-project/
├── schema/schema.sql
├── data/sample_data.sql
├── queries/
│   ├── 01_subqueries_joins.sql
│   ├── 02_window_functions.sql
│   ├── 03_business_questions.sql
│   └── 04_practice_queries.sql
├── docs/ERD.png
└── README.md

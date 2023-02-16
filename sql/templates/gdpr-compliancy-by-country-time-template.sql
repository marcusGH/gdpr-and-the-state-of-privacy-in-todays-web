-- ----- GDPR compliance by Country and Time SQL template -----
-- This query returns a table with various aggregated statistics for each
-- (year, month, tld) combination among the 1 billion requests tracked in
-- the corresponding summary_requests table.
-- 
-- This is done by first creating
-- a req_site table, which has an entry for each of the 1 billion requests and
-- augments this with information about when the request happened (year, month) and
-- whether the request is directed a third-party site such as Google Ads. It also
-- adds various information about the website visited, such as its TLD.
--
-- Then a tech_site table is created, which contains a row for each unique website,
-- identified by pageid. The summary_request table is joined with the technology table
-- to determine which websites use a cookie consent banner and which websites employ
-- Google AdSense, the most widely-used advertisement technology in today's web.
--
-- These two tables are then joined by their pageids, and the results are aggregated by
-- various statistics that might be of interest, such as number of requests to websites
-- with google ads, number of requests to pages with cookie banners, etc.. The COUNT DISTINCT
-- IF statistics only look at website statistics, and could be moved to a different query, but
-- I combine it with this one to reduce the BigQuery bills as I only have 1 TB available.
-- The groupby tld is to ensure we can look at how these statistics vary from EU country to
-- EU country.
-- -----------------------------------------------------------------



-- Construct a table with schema:
--  --------------------------------------------------------------------------------------------------------
--  | pageid | rank | page_url | tld | request_url | is_third_party | year | month |
--  --------------------------------------------------------------------------------------------------------
WITH req_site AS
(SELECT
    -- ## website information ##
    pages.pageid AS pageid,
    pages.rank AS rank,
    pages.url AS page_url,
    -- Find the top-level domain (e.g. .uk, .se, etc.)
    REGEXP_EXTRACT(pages.url, r'[.]([a-z]+)[/]') AS tld,
    -- ## request information ##
    req.url AS request_url,
    -- The request is directed to a third-party google service
    IF(
        {{THIRD_PARTY_COND}}, TRUE, NULL
    ) as is_third_party,
    EXTRACT(year FROM DATE(TIMESTAMP_SECONDS(req.startedDateTime))) AS year,
    EXTRACT(month FROM DATE(TIMESTAMP_SECONDS(req.startedDateTime))) AS month,
    -- The tables we consider in our analyses are the requests, pages and technologies
    -- We perform only inner joins because we only want to analyse results where no data is missing
    FROM `{{REQUESTS_TABLE}}` AS req
    JOIN `{{PAGES_TABLE}}` as pages
    ON
        pages.pageid = req.pageid
),

-- Construct a table with schema:
--  --------------------------------------------------------------
--  | pageid | page_url | use_google_ads | has_cookie_compliance |
--  --------------------------------------------------------------
tech_site AS
(SELECT
    pages.pageid AS pageid,
    ANY_VALUE(pages.url) as page_url,
    -- The website uses Google AdSense
    IF(SUM(IF(tech.app = 'Google AdSense', 1, 0)) > 0, TRUE, NULL) as use_google_ads,
    -- The website has a cookie compliance banner
    IF(SUM(IF(tech.category = 'Cookie compliance', 1, 0)) > 0, TRUE, NULL) AS has_cookie_compliance,
    FROM `{{PAGES_TABLE}}` as pages
    LEFT JOIN `{{TECHNOLOGIES_TABLE}}` as tech
    ON
        tech.url = pages.url
    GROUP BY
        pages.pageid
)

-- Find various aggregation statistics of interest for each (YYYY, MM, TLD) tuple
SELECT
    req_site.year,
    req_site.month,
    req_site.tld,
    -- --- Request statistics ---
    COUNT(req_site.request_url) AS num_requests,
    COUNT(tech_site.has_cookie_compliance) AS num_cookie_compliance,
    COUNT(tech_site.use_google_ads) AS num_google_ads,
    COUNT(req_site.is_third_party) AS num_third_party,
    -- Third party requests should need consent first
    COUNT(IF(tech_site.has_cookie_compliance AND req_site.is_third_party, TRUE, NULL)) AS num_legal_third_party,
    -- Negation of the above
    COUNT(IF((tech_site.has_cookie_compliance IS NULL) AND req_site.is_third_party, TRUE, NULL)) AS num_gdpr_violations,
    -- Need to ask for cookie consent before using google ads
    COUNT(IF(tech_site.use_google_ads AND (tech_site.has_cookie_compliance IS NULL), TRUE, NULL)) AS num_google_ads_violations,
    -- --- Page statistics ---
    -- these statistics are copies of the above, but the DISTINCT IF ensures they count
    -- them across websites instead of across requests
    COUNT(DISTINCT req_site.pageid) AS num_unique_pages,
    COUNT(DISTINCT IF(tech_site.has_cookie_compliance AND req_site.is_third_party, req_site.pageid, NULL)) AS num_unique_pages_legal_third_party,
    COUNT(DISTINCT IF(tech_site.has_cookie_compliance AND tech_site.use_google_ads, req_site.pageid, NULL)) AS num_unique_pages_legal_google_ads,
    COUNT(DISTINCT IF(tech_site.has_cookie_compliance, req_site.pageid, NULL)) AS num_unique_pages_with_cookie_compliance,
    COUNT(DISTINCT IF(req_site.is_third_party, req_site.pageid, NULL)) AS num_unique_pages_with_third_party_requests,
    COUNT(DISTINCT IF(tech_site.use_google_ads, req_site.pageid, NULL)) AS num_unique_pages_with_google_ads,

FROM req_site
JOIN tech_site ON
    req_site.pageid = tech_site.pageid

GROUP BY
    tld, year, month
ORDER BY
    year ASC, month ASC, num_requests DESC

-- Construct a table with schema:
--  --------------------------------------------------------------------------------------------------------
--  | pageid | rank | page_url | tld | has_cookie_compliance | request_url | is_third_party | year | month |
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
    -- Request statistics
    COUNT(req_site.request_url) AS num_requests,
    COUNT(tech_site.has_cookie_compliance) AS num_cookie_compliance,
    COUNT(tech_site.use_google_ads) AS num_google_ads,
    COUNT(req_site.is_third_party) AS num_third_party,
    COUNT(IF(tech_site.has_cookie_compliance AND req_site.is_third_party, TRUE, NULL)) AS num_legal_third_party,
    COUNT(IF((tech_site.has_cookie_compliance IS NULL) AND req_site.is_third_party, TRUE, NULL)) AS num_gdpr_violations,
    COUNT(IF(tech_site.use_google_ads AND (tech_site.has_cookie_compliance IS NULL), TRUE, NULL)) AS num_google_ads_violations,
    -- Page statistics
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

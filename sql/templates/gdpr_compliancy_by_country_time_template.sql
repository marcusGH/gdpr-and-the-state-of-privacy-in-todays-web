-- Construct a table with schema:
--  --------------------------------------------------------------------------------------------------------
--  | pageid | rank | page_url | tld | has_cookie_compliance | request_url | is_third_party | year | month |
--  --------------------------------------------------------------------------------------------------------
WITH request_site_data AS
(SELECT
    -- ## website information ##
    pages.pageid AS pageid,
    pages.rank AS rank,
    pages.url AS page_url,
    -- Find the top-level domain (e.g. .uk, .se, etc.)
    REGEXP_EXTRACT(pages.url, r'[.]([a-z]+)[/]') AS tld,
    -- The site has a cookie compliance banner
    IF(tech.category = 'Cookie compliance', TRUE, NULL) AS has_cookie_compliance,
    -- ## request information ##
    req.url AS request_url,
    -- The request is directed to a third-party google service
    IF(
        {{THIRD_PARTY_COND}}, TRUE, NULL
    ) as is_third_party,
    EXTRACT(year FROM DATE(TIMESTAMP_SECONDS(req.startedDateTime))) AS year,
    EXTRACT(month FROM DATE(TIMESTAMP_SECONDS(req.startedDateTime))) AS month,
    -- The three tables we consider in our analyses are the requests, pages and technologies
    -- We perform only inner joins because we only want to analyse results where no data is missing
    FROM `{{REQUESTS_TABLE}}` AS req
    JOIN `{{PAGES_TABLE}}` as pages
    ON
        pages.pageid = req.pageid
    JOIN `{{TECHNOLOGIES_TABLE}}` as tech
    ON
        tech.url = pages.url
)

-- Find various aggregation statistics of interest for each (YYYY, MM, TLD) tuple
SELECT
    year,
    month,
    tld,
    COUNT(request_url) AS num_requests,
    COUNT(has_cookie_compliance) AS num_cookie_compliance,
    COUNT(is_third_party) AS num_third_party,
    COUNT(IF(has_cookie_compliance AND is_third_party, TRUE, NULL)) AS num_legal_third_party,
    COUNT(IF((has_cookie_compliance IS NULL) AND is_third_party, TRUE, NULL)) AS num_gdpr_violations,
    COUNT(DISTINCT pageid) AS num_unique_pages,
    COUNT(DISTINCT IF(has_cookie_compliance AND is_third_party, pageid, NULL)) AS num_unique_pages_legal_third_party,
    COUNT(DISTINCT IF(has_cookie_compliance, pageid, NULL)) AS num_unique_pages_with_cookie_compliance,
    COUNT(DISTINCT IF(is_third_party, pageid, NULL)) AS num_unique_pages_with_third_party_requests,

FROM request_site_data

GROUP BY
    tld, year, month
ORDER BY
    year ASC, month ASC, tld

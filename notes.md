# Some notes on planning this project

Plotting resources:
* https://urbaninstitute.github.io/r-at-urban/graphics-guide.html#using-libraryurbnthemes


Privacy discussions:
* SRRN paper dowloaded
* https://discuss.httparchive.org/t/tracking-your-privacy-and-the-web/1304
* https://github.com/HTTPArchive/almanac.httparchive.org/blob/main/sql/2020/privacy/percent_of_websites_with_privacy_links.sql
* https://docs.google.com/document/d/1hIllsWd_IqfYuGT_qUFA2ruoQaIvcbuYpNHJLB4AqkU/edit
* https://github.com/HTTPArchive/almanac.httparchive.org/issues/913#903


Data science ideas:
* https://discuss.httparchive.org/t/tracking-page-weight-over-time/1049/3
* https://discuss.httparchive.org/t/number-of-tracking-cookies-a-website-uses-1st-3rd-parties/1946
* https://discuss.httparchive.org/t/tracking-your-privacy-and-the-web/1304
* https://github.com/max-ostapenko/we-value-your-privacy


* https://docs.google.com/document/d/1hIllsWd_IqfYuGT_qUFA2ruoQaIvcbuYpNHJLB4AqkU/edit
* https://discuss.httparchive.org/t/chapter-10-privacy/2046
* Finding the number of third-party trackers in requests
* https://discuss.httparchive.org/t/tracking-your-privacy-and-the-web/1304
* The iab tcf is the cookie consent banner thing in requests
* Inspiration for analysis:
* https://github.com/RUB-SysSec/we-value-your-privacy
* https://arxiv.org/pdf/1808.05096.pdf
* Downloaded SSRN paper

Idea:
* Filter non-eu TLD websites, so know hosted in EU and target audience in EU
* Filter out non-advertisement tracking?
  * Group results by month
* Look at number of third-party trackers in requests throughout that month (focus just on google-analytics and facebook, or group by most popular ones)
  * Look at number of privacy-words in cookie banners in those requests for each month
* Also get total number of those requests per month (not that useful, since when visit one website, make multiple requests)
  * Final data:
  * For each month: Number of eu-pages, number of eu-pages with privacy words, number of eu-pages with ad trackers
  * For each month: Total number of third-party ads requests, total number of third-party ad requests emitting from sites with no privacy words
  * vertical bar for gdpr introduction

  Weight of the web literally:
  https://adamant.typepad.com/seitz/2006/10/weighing_the_we.html



Getting the year and month from a request:
```
select
extract(month from date(timestamp_seconds(requests.startedDateTime))) as month,
extract(year from date(timestamp_seconds(requests.startedDateTime))) as year,
regexp_extract(pages.url, r'[.]([a-z]+)[/]') as tld,


from summary_requests joined on summary_pages

...


group by year, month, tld
```


https://www.chronicle.com/
gives
https://www.google-analytics.com/analytics.js



googletagservices.com/tag/js/gpt.js
googletagservices.com/tag/js
pagead2.googlesyndication.com/pagead
googleadservices.com/pagead/
stats.g.doubleclick.net/r/collect
securepubads.g.doubleclick.net/gpt/
googleads.g.doubleclick.net/


CONTAINS_SUBSTR(req.url, "googleads.g.doubleclick.net") OR
CONTAINS_SUBSTR(req.url, "googleadservices.com") OR
CONTAINS_SUBSTR(req.url, "googletagservices.com") OR
CONTAINS_SUBSTR(req.url, "pagead2.googlesyndication.com") OR
CONTAINS_SUBSTR(req.url, "securepubads.g.doubleclick.net") OR
CONTAINS_SUBSTR(req.url, "stats.g.doubleclick.net")




# Disclaimer



SELECT pageid, rank, page_url, tld, has_cookie_compliance, is_third_party, request_url FROM request_site_data
where tld = 'no'
order by is_third_party DESC, has_cookie_compliance DESC



All data collected by httparchive
from requests made between 1. january 2023 and 16. january 2023 (first two weeks of January)

# Why GoogleAds

```
  with ads as (
      select category, app from 
      `httparchive.technologies.2018_01_01_desktop`
      where category = 'Advertising Networks'
      )

select app, count(0)
  from ads
  group by app
```


https://arxiv.org/pdf/1808.05096.pdf
https://github.com/RUB-SysSec/we-value-your-privacy



gdpr: https://gdpr.eu/article-7-how-to-get-consent-to-collect-personal-data/


## Plotting

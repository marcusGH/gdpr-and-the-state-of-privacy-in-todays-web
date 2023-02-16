# Title

Overview of project, brief introduction to dataset, due to size, stored in Google BigQuery and access through an R api

## Repository overview


## Reproducing the results

%% Change title?

### Requirements

* The `R` packages found in [`install_requirements.R`](install_requirements.R)
* [Lato font pack](https://fonts.google.com/specimen/Lato)



Required R packages:, API key, instructions on setting up

**Acquiring a Google BigQuery billing key**

To access the data with the Google BigQuery R API, a billing key is required.
You will not need a credit card to set this up as Google BigQuery has a free tier
that allows up to 1TB of free data processing per month. To acquire your billing
key, you should do the following:
1. Create a Google account
2. Navigate to the [Google Cloud Projects Page](https://console.cloud.google.com/start), following relevant instructions if prompted. Once you have logged in, you should see a page like this:
  ![welcome page for Google Cloud projects](https://user-images.githubusercontent.com/29378769/218258002-3dbacd16-79a5-4104-8464-4d4c62122bd0.png)
3. Click on `Select a project` and create a new project with a name of your choice. Remember to note down the project ID of your created project. This will be used as the billing key.
4. Save the billing key to your `.Rprofile` file by adding `options(bigquery_billing_ID="MY-PROJECT-ID")`. If you are on a UNIX-like operating system, this can be done with:
   ```
   BILLING_ID="MY-PROJECT-ID" ; echo "options(bigquery_billing_ID='${BILLING_ID}')" >> ~/.Rprofile
   ```
   Remember to replace `MY-PROJECT-ID` with the project ID of the project you created in step 3
5. To test that everything is working correctly, run TODO

### Instructions

TODO


Set your working directory to the root of the project.


Note: This query does a join on a 978 GB table and a 1 GB table, so it will use about 170 GB of Bigquery credits.


## Discussion

Focus on websites using Google AdSense to deliver ads on their website
According to
[Google's AdSense Help site](https://support.google.com/adsense/answer/9007336?hl=en-GB),
both personalised and non-personalised advertisements requires the user's consent if
the website is hosted in a
[ePrivacy Directive](https://en.wikipedia.org/wiki/Privacy_and_Electronic_Communications_Directive_2002)-particpating
country. Therefore, websites found by the `httparchive` to use this technology should also
employ a Cookie Banner to acquire the user's consent. Otherwise, they would be violating these
rules.



https://www.cookiechoices.org/intl/en-GB/ needed?
https://ads.google.com/intl/en_uk/home/faq/gdpr/

## Blocklist

Could use
https://github.com/nickspaargaren/no-google

but covers to many, rather a few and 



## Reflective summary

guidelines not met:
* Full-width graphics
* figure number
* bar charts, avoiding vertical grid lines, could add entries for EU average, all sites average and non-EU average, but could be misleading as these are not necesarily GDPR violations

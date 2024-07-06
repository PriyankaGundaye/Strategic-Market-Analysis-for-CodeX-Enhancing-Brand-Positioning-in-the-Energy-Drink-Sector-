create database marketing_data;
/*1. Demographic Insights*/
/*a. Who prefers energy drink more? (male/female/non-binary?)*/
select dr.gender,count(*) as preference_count from dim_repondents dr
inner join fact_survey_responses fsr
on dr.Respondent_ID = fsr.Respondent_ID
group by dr.gender
order by preference_count desc;


/*b. Which age group prefers energy drinks more?*/
select dr.age,count(*)  as age_group_count from dim_repondents dr
inner join fact_survey_responses fsr
on dr.Respondent_ID = fsr.Respondent_ID
group by dr.age
order by age_group_count desc;

/*c. Which type of marketing reaches the most Youth (15-30)*/
with cte_1 as 
( select fsr.Respondent_ID, dr.age , fsr.Marketing_channels  from dim_repondents dr
inner join fact_survey_responses fsr
on dr.Respondent_ID = fsr.Respondent_ID
where dr.Age = "15-18" or dr.Age = "19-30"
)
select Marketing_channels, count(*) as Marketing_channels_count from cte_1
group by Marketing_channels
order by Marketing_channels_count desc;


/*2. Consumer Preferences:*/

/*a. What are the preferred ingredients of energy drinks among respondents?*/
select ingredients_expected , count(*) as count 
from fact_survey_responses
group by ingredients_expected
order by  count desc ;


/*b. What packaging preferences do respondents have for energy drinks?*/
select Packaging_preference , count(*) as count 
from fact_survey_responses
group by Packaging_preference
order by  count desc ;

/*3. Competition Analysis:*/
/*a. Who are the current market leaders?*/
select Current_brands , count(*) as brand_count 
from fact_survey_responses
group by Current_brands
order by  brand_count desc ;

/*b. What are the primary reasons consumers prefer those brands over ours?*/
WITH cte_reasons AS (
    SELECT 
        Current_brands, 
        Reasons_for_choosing_brands,
        COUNT(*) AS reason_count
    FROM fact_survey_responses
    GROUP BY Current_brands, Reasons_for_choosing_brands
),
cte_percentage_share AS (
    SELECT 
        Current_brands,
        Reasons_for_choosing_brands,
        ROUND(
            (reason_count * 1.0 / 
            SUM(reason_count) OVER (PARTITION BY Current_brands)) * 100, 2) AS percentage_share
    FROM cte_reasons
)
SELECT 
    Current_brands, 
    COALESCE(MAX(CASE WHEN Reasons_for_choosing_brands = 'Brand reputation' THEN percentage_share END), 0) AS Brand_reputation,
    COALESCE(MAX(CASE WHEN Reasons_for_choosing_brands = 'Taste/flavor preference' THEN percentage_share END), 0) AS Taste_flavor_preference,
    COALESCE(MAX(CASE WHEN Reasons_for_choosing_brands = 'Availability' THEN percentage_share END), 0) AS Availability,
    COALESCE(MAX(CASE WHEN Reasons_for_choosing_brands = 'Effectiveness' THEN percentage_share END), 0) AS Effectiveness,
    COALESCE(MAX(CASE WHEN Reasons_for_choosing_brands = 'Other' THEN percentage_share END), 0) AS Other
FROM cte_percentage_share
GROUP BY Current_brands
ORDER BY Current_brands;



/*4. Marketing Channels and Brand Awareness:*/
/*a. Which marketing channel can be used to reach more customers?*/

WITH cte_marketing_channel AS (
    SELECT 
        Current_brands, 
        Marketing_channels, 
        COUNT(*) AS count_Marketing_channels
    FROM fact_survey_responses
    GROUP BY Current_brands, Marketing_channels
),
cte_percentage_share AS (
    SELECT 
        Current_brands,
        Marketing_channels,
        ROUND(
            (count_Marketing_channels * 1.0 / 
            SUM(count_Marketing_channels) OVER (PARTITION BY Current_brands)) * 100, 2
        ) AS percentage_share
    FROM cte_marketing_channel
)
SELECT 
    Current_brands,
    COALESCE(MAX(CASE WHEN Marketing_channels = 'Online ads' THEN percentage_share END), 0) AS Online_ads,
    COALESCE(MAX(CASE WHEN Marketing_channels = 'TV commercials' THEN percentage_share END), 0) AS TV_commercials,
    COALESCE(MAX(CASE WHEN Marketing_channels = 'Outdoor billboards' THEN percentage_share END), 0) AS Outdoor_billboards,
    COALESCE(MAX(CASE WHEN Marketing_channels = 'Other' THEN percentage_share END), 0) AS Other,
    COALESCE(MAX(CASE WHEN Marketing_channels = 'Print media' THEN percentage_share END), 0) AS Print_media
FROM cte_percentage_share
GROUP BY Current_brands
ORDER BY Current_brands;


/*5. Brand Penetration:*/
/*a. What do people think about our brand? (overall rating)*/
select Brand_perception, count(*) as Brand_rating
from fact_survey_responses
group by Brand_perception
order by Brand_rating desc;

select Taste_experience, count(*) as Taste_rating
from fact_survey_responses
group by Taste_experience
order by Taste_rating desc;

/*b. Which cities do we need to focus more on?*/
SELECT c.city,
count(*) Not_Heard_before_count 
 FROM dim_cities c 
 inner join dim_repondents r 
 on c.City_ID = r.City_ID
 inner join 
 fact_survey_responses fs
 on fs.Respondent_ID = r.Respondent_ID
 where fs.current_brands = 'CodeX' and fs.Heard_before = 'No'
 group by c.city
 order by Not_Heard_before_count desc;


/*6. Purchase Behavior:*/
/*a. Where do respondents prefer to purchase energy drinks?*/
select Purchase_location , 
count(*) Purchase_loation_count 
from fact_survey_responses 
group by Purchase_location;

/*b. What are the typical consumption situations for energy drinks among respondents?*/
select Consume_reason , 
count(*) Consume_reason_count 
from fact_survey_responses 
group by Consume_reason;

/*c. What factors influence respondents' purchase decisions, such as price range and limited edition packaging?*/
select Limited_edition_packaging, count(*) as Survey_answer
from fact_survey_responses
group by Limited_edition_packaging
order by Survey_answer desc;

select Price_range, count(*) as desired_price
from fact_survey_responses
group by Price_range
order by desired_price desc;

/*7. Product Development*/
/*a. Which area of business should we focus more on our product development? 
(Branding/taste/availability)*/
select Reasons_for_choosing_brands, count(*) as reasons
from fact_survey_responses
group by Reasons_for_choosing_brands
order by reasons desc;






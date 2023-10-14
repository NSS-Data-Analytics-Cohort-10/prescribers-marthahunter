-- 1a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.

SELECT
	prescription.npi, sum(total_claim_count) AS total_claim_count
FROM prescriber
LEFT JOIN prescription
USING (npi)
GROUP BY (prescription.npi)
ORDER BY total_claim_count DESC
LIMIT 5;

-- Provider 1881634483: 99,707 claims

-- 1b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name, specialty_description, and the total number of claims.

SELECT
	nppes_provider_first_name,
	nppes_provider_last_org_name,
	specialty_description,
	(SUM(total_claim_count)) AS total_claim_count
FROM prescriber
	LEFT JOIN prescription
	USING (npi)
WHERE total_claim_count IS NOT NULL
GROUP BY prescription.npi,
	nppes_provider_first_name,
	nppes_provider_last_org_name,
	specialty_description
ORDER BY total_claim_count DESC
LIMIT 5;

-- Bruce Pendley in Family Practice: 99,707 claims

-- 2a. Which specialty had the most total number of claims (totaled over all drugs)?

SELECT
	specialty_description,
	(SUM(total_claim_count)) AS total_claim_count
FROM prescriber
	LEFT JOIN prescription
	USING (npi)
GROUP BY specialty_description
ORDER BY total_claim_count DESC;

-- Family Practice: 975,2347 claims

-- 2b. Which specialty had the most total number of claims for opioids?

SELECT
	specialty_description,
	(SUM(total_claim_count)) AS total_claim_count
FROM drug
	LEFT JOIN prescription
	USING (drug_name) 
	LEFT JOIN prescriber
	USING (npi)
WHERE opioid_drug_flag = 'Y'
GROUP BY specialty_description
ORDER BY total_claim_count DESC;

-- Nurse Practitioner with 900,845 claims with opioid drug flags

-- 2c. Challenge Question: Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?

-- 2d. Difficult Bonus: Do not attempt until you have solved all other problems! For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?

-- 3a. Which drug (generic_name) had the highest total drug cost?

SELECT
	generic_name,
	CAST(SUM(total_drug_cost) AS MONEY) AS total_drug_cost
FROM prescription
	LEFT JOIN drug
	USING (drug_name)
WHERE total_drug_cost IS NOT NULL
GROUP BY generic_name
ORDER BY total_drug_cost DESC
LIMIT 50;

-- INSULIN GLARGINE,HUM.REC.ANLOG: $104,264,066.35

-- 3b. Which drug (generic_name) has the hightest total cost per day? Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.

SELECT
	generic_name,
	CAST((SUM(total_drug_cost)/SUM(total_day_supply)) AS MONEY) AS cost_per_day
FROM prescription
	LEFT JOIN drug
	USING (drug_name)
WHERE total_drug_cost IS NOT NULL
GROUP BY generic_name
ORDER BY cost_per_day DESC;

-- C1 ESTERASE INHIBITOR, $3,495.22

-- 4a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs.

SELECT 
	drug_name, 
	CASE 
		WHEN opioid_drug_flag = 'Y' THEN 'opioid'
		WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
		ELSE 'neither' 
	END AS drug_type
FROM drug;

-- 4b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.

SELECT
	CASE
		WHEN drug.opioid_drug_flag = 'Y'
		THEN 'opioid'
		WHEN drug.antibiotic_drug_flag = 'Y'
		THEN 'antibiotic'
		ELSE 'neither'
	END AS drug_type,
	CAST(SUM(prescription.total_drug_cost) AS MONEY) AS total_spent
	FROM drug
		LEFT JOIN prescription
		USING (drug_name)
	GROUP BY drug_type
	ORDER BY total_spent DESC;

-- Opioids had a higher total drug cost ($105,080,626.37)

-- 5a. How many CBSAs are in Tennessee? Warning: The cbsa table contains information for all states, not just Tennessee.

SELECT COUNT (cbsa) AS cbsa_tn
FROM cbsa
WHERE cbsaname iLIKE '%, TN';

-- 33

-- 5b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.

SELECT cbsaname, SUM(population) AS population
FROM cbsa
LEFT JOIN population
USING (fipscounty)
WHERE population IS NOT NULL
GROUP BY cbsaname
ORDER BY population DESC;

-- 34980 with a population of 1,830,410

-- 5c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.

--DRAFT
SELECT population, fips_county.county,fips_county.state
FROM population
FULL JOIN fips_county
USING (fipscounty)
WHERE population.fipscounty NOT IN 
	(SELECT
	 fipscounty
	 FROM cbsa) 
ORDER BY population DESC
LIMIT 1;

-- Sevier County: 95523

-- 6a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.

SELECT drug_name, total_claim_count
FROM prescription
WHERE total_claim_count>=3000;

-- 6b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.

SELECT drug_name, total_claim_count,
CASE
	WHEN opioid_drug_flag = 'Y'
	THEN 'Y'
	ELSE 'N'
END AS opioid
FROM prescription
LEFT JOIN drug
USING (drug_name)
WHERE total_claim_count>=3000;

-- 6c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.



-- 7. The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid. Hint: The results from all 3 parts will have 637 rows.

-- 7a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Management) in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). Warning: Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.

-- 7b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).

-- 7c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.
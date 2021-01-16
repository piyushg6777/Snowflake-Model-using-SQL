CREATE DATABASE  IF NOT EXISTS `aly6030_final_project`;
USE `aly6030_final_project`;

-- To see the output of the table imported from given csv file

SELECT * FROM fact_drug;
SELECT * FROM dim_member;
SELECT * FROM dim_drug_form_code;
SELECT * FROM dim_drug_ndc;
SELECT * FROM dim_brand_generic;



#assigning primary keys for each table
ALTER TABLE dim_member
ADD PRIMARY KEY (member_id);

ALTER TABLE dim_brand_generic
ADD PRIMARY KEY (brand_generic);

ALTER TABLE dim_drug_form_code
ADD PRIMARY KEY (drug_form_code);

ALTER TABLE dim_drug_ndc
ADD PRIMARY KEY (drug_ndc);

ALTER TABLE fact_drug
ADD ID INT NOT NULL AUTO_INCREMENT PRIMARY KEY;


#assigning foreign keys for each table
ALTER TABLE fact_drug
ADD FOREIGN KEY fact_drug_member_id_fk(member_id)
REFERENCES dim_member(member_id)
ON DELETE SET NULL
ON UPDATE SET NULL;

ALTER TABLE fact_drug
ADD FOREIGN KEY fact_drug_drug_ndc_fk(drug_ndc)
REFERENCES dim_drug_ndc(drug_ndc)
ON DELETE SET NULL
ON UPDATE SET NULL;

ALTER TABLE fact_drug
ADD FOREIGN KEY fact_drug_brand_generic_fk(brand_generic)
REFERENCES dim_drug_ndc(brand_generic)
ON DELETE SET NULL
ON UPDATE SET NULL;

ALTER TABLE fact_drug
ADD FOREIGN KEY fact_drug_drug_form_code_fk(drug_form_code)
REFERENCES dim_drug_form_code(drug_form_code)
ON DELETE SET NULL
ON UPDATE SET NULL;

#####################################################
# PART 4 (1)
SELECT dim_drug_ndc.drug_name, COUNT(fact_drug.member_id) as num_prescriptions
FROM dim_drug_ndc JOIN fact_drug 
ON dim_drug_ndc.drug_ndc = fact_drug.drug_ndc
GROUP BY dim_drug_ndc.drug_name;

# PART 4 (2)
SELECT CASE
WHEN dim_member.member_age > 65 THEN '65+'
WHEN dim_member.member_age < 65 THEN '<65'
END AS age_group,
COUNT(DISTINCT dim_member) AS number_members,
SUM(fact_drug.copay) AS sum_copay,
SUM(fact_drug.insurancepaid) AS num_prescriptions
FROM dim_member
INNER JOIN fact_drug
ON dim_member.member_id = fact_drug.member_id
GROUP BY age_group;

# PART 4 (3)

ALTER TABLE fact_drug
MODIFY fill_date DATE;

CREATE TABLE fill_fact AS 
SELECT dim_member.member_id, dim_member.member_first_name,dim_member.member_last_name, dim_drug_ndc.drug_name,
str_to_date(fact_drug.fill_date, '%m%d%y') AS fill_date_fixed, fact_drug.insurancepaid
FROM dim_member INNER JOIN fact_drug 
 ON dim_member.member_id = fact_drug.member_id
INNER JOIN dim_drug_ndc
 ON dim_drug_ndc.drug_ndc = fact_drug.drug_ndc; 

SELECT * FROM fill_fact;
CREATE TABLE insurancepaid_info AS
SELECT member_id, member_first_name, member_last_name, drug_name, fill_date_fixed, insurancepaid,
ROW_NUMBER() OVER(PARTITION BY member_id ORDER BY member_id, fill_date_fixed DESC) AS fill_times
FROM fill_fact;


SELECT * FROM insurance_paid_info WHERE fill_times=1;



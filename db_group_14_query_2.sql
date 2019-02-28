select distinct email 
from interview inner join interview_person using(articleid) 
inner join person using (personid) 
inner join photographer using(personid) inner join writer using(personid)
where consenttopublish = true
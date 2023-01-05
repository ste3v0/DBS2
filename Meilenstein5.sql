--5.
select * into Auftrag2 from trommelhelden..quelleAuftrag2011
select * into Montage2 from trommelhelden..quelleMontage2011

--5.a
select Count(*) from Auftrag2
--TableScan --> Aggregate

--5.b
alter Table Auftrag2 add PRIMARY KEY (Aufnr)

--5.c
select Count(*) from Auftrag2
--CLUSTERED Index Scan --> Aggregate

--5.d
alter Table Auftrag2 drop constraint PK__Auftrag2__D569023BABFC27D9



--6
SELECT mitid, COUNT(*)
FROM auftrag2
WHERE anfahrt = 5 and AufDat BETWEEN '2011-01-01' AND '2011-02-01'
GROUP BY mitid
--78% TableScan, 22% Sort

Create Index idx_Auftrag2_Anfahrt_Aufdat on Auftrag2(Anfahrt,Aufdat)
drop index idx_Auftrag2_Anfahrt_Aufdat on AUftrag2

SELECT mitid, COUNT(*)
FROM auftrag2
WHERE anfahrt = 5 and AufDat BETWEEN '2011-01-01' AND '2011-08-01'
GROUP BY mitid
--Index Seek 1%, RID Lookup 95%, Sort 4%    

select * from auftrag2
--7

SELECT k.KunNr, k.KunName
FROM kunde k, auftrag2 a
WHERE k.KunNr=a.KunNr
AND a.anfahrt=80

SELECT k.KunNr, k.KunName
FROM kunde k JOIN auftrag2 a ON
k.KunNr=a.KunNr
AND a.anfahrt=80

SELECT k.KunNr, k.KunName
FROM kunde k, auftrag2 a
WHERE a.anfahrt=80
AND k.KunNr=a.KunNr

SELECT k.KunNr, k.KunName
FROM auftrag2 a JOIN kunde k ON
k.KunNr=a.KunNr
AND a.anfahrt=80


--8

SELECT a.aufnr, erldat, k.kunort, SUM(anzahl * etpreis) FROM auftrag2 a
    JOIN montage2 m ON a.aufnr = m.aufnr
    JOIN ersatzteil e ON m.etid = e.etid 
    JOIN mitarbeiter ma ON a.mitid = ma.mitid 
    JOIN kunde k ON a.kunnr = k.kunnr
GROUP BY a.aufnr, erldat, k.kunort

set Showplan_all off
set forceplan OFF
sp_help
-- Meilenstein 3
-- Benutzerdefinierte Funktionen
--1.1
create FUNCTION kalkAnfahrtspreis (@Weg int)
RETURNS SMALLMONEY
AS
begin
declare @Anfahrtspreis Smallmoney

if @weg * 2.5 < 30 set @Anfahrtspreis = 30

else set @Anfahrtspreis = @weg * 2.5

return @anfahrtspreis
end;

select Anfahrt, dbo.KalkAnfahrtspreis (Anfahrt)
from Auftrag
where Anfahrt is not NULL

--1.2
CREATE FUNCTION Bestellen (@Mindestbestand int)
returns Table
as
RETURN(
    select EtID 
    from Ersatzteil
    where EtAnzLager < @Mindestbestand
);

select * from dbo.bestellen(1000)

--2.1a
alter TABLE mitarbeiter add CONSTRAINT MitJobStandard DEFAULT 'Monteur' for MitJob

insert into Mitarbeiter 
values (113,'Muster','Max', '1993-07-2',default ,88,1)

select * from Mitarbeiter
DELETE from mitarbeiter where MitName = 'Muster'

--2.1b
alter table auftrag add constraint AufDatStandart DEFAULT GETDATE() for AufDat
insert into Auftrag
values (3713, Null,1469,default, null,null,null,null)

select *from Auftrag where Aufnr =3713

delete from Auftrag where Aufnr =3713


--2.2a
alter TABLE auftrag add CONSTRAINT CK_Erldat check (DateDiff(dd,erldat,aufdat)>0 or erldat is null)
sp_help mitarbeiter

--2.2b
alter table mitarbeiter add CONSTRAINT CK_MitId check (Len(MitID)=3 and MitID is not null)
sp_help auftrag


--2.3
select Aufnr,AufDat from Auftrag where AufDat=(select MIN(AufDat)from Auftrag where MONTH(AufDat)=5)
select * from Montage m join 
(select Aufnr from Auftrag where AufDat=(select MIN(AufDat)from Auftrag where MONTH(AufDat)=5)) a on m.AufNr=a.Aufnr

--backup
select * into Auftrag2 from auftrag where AufDat=(select MIN(AufDat)from Auftrag where MONTH(AufDat)=5)
select m.aufnr,m.EtID,m.Anzahl into Monatge2 from Montage m join 
(select Aufnr from Auftrag where AufDat=(select MIN(AufDat)from Auftrag where MONTH(AufDat)=5)) a on m.AufNr=a.Aufnr

--fremdschlüssel mit löschweitergabe
alter TABLE montage drop constraint FK__Montage__AufNr__7A672E12
alter table montage add CONSTRAINT co_forkey_aufnr foreign key (aufnr) REFERENCES Auftrag (aufnr) on update CASCADE on DELETE CASCADE

--löschen
DELETE from Auftrag where AufDat=(select MIN(AufDat)from Auftrag where MONTH(AufDat)=5)

--3

create TRIGGER InsertMitarbeiterStundensatz on Mitarbeiter for INSERT, UPDATE, DELETE
as
if (select COUNT(MitID) from Mitarbeiter where (MitJob = 'Monteur' or MitJob= 'Meister')and MitStundensatz is null)>0 
    begin
        Print 'Bitte Stundensatz angeben'
        ROLLBACK TRANSACTION
    END


insert into Mitarbeiter VALUEs (113,'Kühnel','Georg','2002-07-13', 'Azubi', Null,Null)

UPDATE Mitarbeiter 
set MitJob = 'Monteur',
Mitstundensatz = 80
where MitID = 113

--3.2

select * from Auftrag where ErlDat is null and Dauer is not null --es gibt keine Aufträge deren Dauer fest steht, aber es kein Erldat gibt, also reicht Dauer is null als Filter

create TRIGGER RechnungAbgeschlossen on Rechnung for INSERT, UPDATE, DELETE
AS
if (select Count(r.AufNr) from Rechnung r join Auftrag a on r.AufNr=a.Aufnr where a.Dauer is null )>0
    begin 
        PRINT 'Der Auftrag ist noch nicht erledigt'
        ROLLBACK TRANSACTION
        RETURN
    END

if (select Count(r.Aufnr) from Rechnung r join Auftrag a on r.AufNr=a.Aufnr where r.RechBetrag< dbo.kalkAnfahrtspreis(a.Anfahrt))>0
    BEGIN
        print 'Der Rechnungsbetrag wurde falsch kalkuliert'
        ROLLBACK TRANSACTION
    END



drop trigger RechnungAbgeschlossen

DELETE from Rechnung
--3.2a
insert into Rechnung values (1281,10026, '2022-10-15', 154.50)
insert into Rechnung values (1152,10218, '2022-10-15', 180)
insert into Rechnung values (1213,10164, '2022-10-16', 60)

--3.2b
insert into Rechnung select KunNr, Aufnr, ErlDat, 180 
from Auftrag where Aufnr in (10050,10052,10060)

insert into Rechnung select KunNr, Aufnr, ErlDat, 180 
from Auftrag where Aufnr in (10056,10059,10061)

select * from Rechnung

sp_help rechnung
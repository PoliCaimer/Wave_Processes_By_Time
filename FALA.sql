Publish data
 where sch = 'place for waveID'
|
[select data1.schbat AS FALA,
        data1.w_systemie,
        data1.uwolniona_fala,
        data1.Assembly,
        data1.Decanting,
        data1.pierwsze_worki,
        data1.ostatnie_worki,
        data1.pierwsze_worki_PT,
        data1.ostatnie_worki_PT,
        data2.start_alokacji,
        data2.koniec_alokacji,
        data3.pierwszy_dispatch_wysylki,
        data3.ostatni_dispatch_wysylki
   from (select distinct sl.schbat,
                min(o.entdte) AS w_systemie,
                pb.adddte AS uwolniona_fala,
                udw.as_date AS Assembly,
                udw.dc_date AS Decanting,
                min(pv.pckdte) AS pierwsze_worki,
                max(pv.pckdte) AS ostatnie_worki,
                min(pvm.pckdte) AS pierwsze_worki_PT,
                max(pvm.pckdte) AS ostatnie_worki_PT
           from (select distinct ordnum,
                        ship_id,
                        schbat
                   from shipment_line
                  where schbat = @sch
                    and linsts != 'B'
                 union
                 select distinct ordnum,
                        ship_id,
                        schbat
                   from ar_shipment_line
                  where schbat = @sch
                    and linsts != 'B') sl
           join (select distinct ordnum,
                        entdte,
                        uc_pass_str5
                   from ord
                 union
                 select distinct ordnum,
                        entdte,
                        uc_pass_str5
                   from ar_ord) o
             on sl.ordnum = o.ordnum
           join (select adddte,
                        schbat
                   from pckbat
                  where schbat = @sch) pb
             on sl.schbat = pb.schbat
           join (select diq_wave,
                        as_date,
                        dc_date
                   from uc_diq_wave) udw
             on o.uc_pass_str5 = udw.diq_wave
           join (select schbat,
                        ordnum,
                        pckdte
                   from pckwrk_view
                  where schbat = @sch
                    and srcloc != 'MEZZANINE'
                 union
                 select schbat,
                        ordnum,
                        pckdte
                   from ar_pckwrk_view
                  where schbat = @sch
                    and srcloc != 'MEZZANINE') pv
             on sl.schbat = pv.schbat
            and sl.ordnum = pv.ordnum
           join (select schbat,
                        ordnum,
                        pckdte
                   from pckwrk_view
                  where schbat = @sch
                    and srcloc = 'MEZZANINE'
                 union
                 select schbat,
                        ordnum,
                        pckdte
                   from ar_pckwrk_view
                  where schbat = @sch
                    and srcloc = 'MEZZANINE') pvm
             on sl.schbat = pvm.schbat
            and sl.ordnum = pvm.ordnum
          group by sl.schbat,
                pb.adddte,
                udw.as_date,
                udw.dc_date) data1
   join (select distinct sl.schbat,
                min(oa.trndte) AS start_alokacji,
                max(oa.trndte) AS koniec_alokacji
           from (select distinct ordnum,
                        schbat
                   from shipment_line
                  where schbat = @sch
                    and linsts != 'B'
                 union
                 select distinct ordnum,
                        schbat
                   from ar_shipment_line
                  where schbat = @sch
                    and linsts != 'B') sl
           join (select distinct ordnum,
                        schbat,
                        trndte
                   from ordact
                  where schbat = @sch
                    and actcod = 'SALC'
                 union
                 select distinct ordnum,
                        schbat,
                        trndte
                   from ar_ordact
                  where schbat = @sch
                    and actcod = 'SALC') oa
             on sl.ordnum = oa.ordnum
            and sl.schbat = oa.schbat
          group by sl.schbat) data2
     on data1.schbat = data2.schbat
   join (select sl.schbat,
                min(t.dispatch_dte) AS pierwszy_dispatch_wysylki,
                max(t.dispatch_dte) AS ostatni_dispatch_wysylki
           from (select distinct ordnum,
                        schbat,
                        ship_id
                   from shipment_line
                  where schbat = @sch
                    and linsts != 'B'
                 union
                 select distinct ordnum,
                        schbat,
                        ship_id
                   from ar_shipment_line
                  where schbat = @sch
                    and linsts != 'B') sl
           join ship_struct_view ssv
             on sl.ship_id = ssv.ship_id
           join trlr t
             on ssv.trlr_id = t.trlr_id
          group by sl.schbat) data3
     on data1.schbat = data3.schbat]

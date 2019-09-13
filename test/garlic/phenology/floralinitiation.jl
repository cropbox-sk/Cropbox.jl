@system FloralInitiation(Stage, Germination) begin
    sun(weather) => weather.sun ~ ::Sun

    critical_photoperiod: critPPD => 12.5 ~ preserve(u"hr", parameter)

    floral_initiateable(germinated) ~ flag

    #FIXME: implement Sun
    floral_initiated(critPPD, day_length=sun.day_length, day=sun.day) => begin
        #FIXME solstice consideration is broken (flag turns false after solstice) and maybe unnecessary
        # w = self.pheno.weather
        # solstice = w.time.tz.localize(datetime.datetime(w.time.year, 6, 21))
        # # no MAX_LEAF_NO implied unlike original model
        # w.time <= solstice and w.day_length >= self.critical_photoperiod
        day_length >= critPPD && day <= 171
    end ~ flag(oneway)

    floral_initiating(a=floral_initiateable, b=floral_initiated) => (a && !b) ~ flag

    # #FIXME postprocess similar to @produce?
    # def finish(self):
    #     GDD_sum = self.pheno.gdd_recorder.rate
    #     print(f"* Floral initiation: time = {self.time}, GDDsum = {GDD_sum}")
end

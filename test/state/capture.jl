@testset "capture" begin
    @testset "basic" begin
        @system SCapture(Controller) begin
            a => 1 ~ track
            b(a) => a + 1 ~ capture
            c(a) => a + 1 ~ accumulate
        end
        s = instance(SCapture)
        @test s.b' == 0 && s.c' == 0
        update!(s)
        @test s.b' == 2 && s.c' == 2
        update!(s)
        @test s.b' == 2 && s.c' == 4
    end

    @testset "time" begin
        @system SCaptureTime(Controller) begin
            t(x=context.clock.tick) => 2x ~ track(u"hr")
            a => 1 ~ track
            b(a) => a + 1 ~ capture(time=t)
            c(a) => a + 1 ~ accumulate(time=t)
        end
        s = instance(SCaptureTime)
        @test s.b' == 0 && s.c' == 0
        update!(s)
        @test s.b' == 4 && s.c' == 4
        update!(s)
        @test s.b' == 4 && s.c' == 8
    end

    @testset "unit hour" begin
        @system SCaptureUnitHour(Controller) begin
            a => 1 ~ capture(u"hr")
        end
        s = instance(SCaptureUnitHour)
        @test iszero(s.a')
        update!(s)
        @test s.a' == 1u"hr"
        update!(s)
        @test s.a' == 1u"hr"
    end

    @testset "unit day" begin
        @system SCaptureUnitDay(Controller) begin
            a => 1 ~ capture(u"d")
        end
        s = instance(SCaptureUnitDay)
        @test iszero(s.a')
        update!(s)
        @test s.a' == 1u"hr"
        update!(s)
        @test s.a' == 1u"hr"
    end
end

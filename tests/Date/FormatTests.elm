module Date.FormatTests where

{- Test date format.

Copyright (c) 2016 Robin Luiten
-}

import Date exposing (Date)
import ElmTest exposing (..)
import Time exposing (Time)

-- import Date.Config as Config
import Date.Core as Core
import Date.Format as Format
import Date.Config.Config_en_us as Config_en_us
import Date.Config.Config_en_au as Config_en_au
import Date.Period as DPeriod exposing (Period (Hour))


tests : Test
tests =
  suite "Date.Format tests"
    [ formatTest ()
    , formatUtcTest ()
    , formatOffsetTest ()
    ]


{-

Time : 1407833631116
  is : 2014-08-12T08:53:51.116+00:00
  is : 2014-08-12T18:53:51.116+10:00
  is : 2014-08-12T04:53:51.116-04:00

Time : 1407855231116
  is : 2014-08-12T14:53:51.116+00:00
  is : 2014-08-13T00:53:51.116+10:00


Using floor here to work around bug in Elm 0.16 on Windows
that cant produce this as integer into the javascript source.

-}
aTestTime = floor 1407833631116.0
aTestTime2 = floor 1407855231116.0
aTestTime3 = floor -48007855231116.0 -- year 448

aTestTime4 = floor -68007855231116.0 -- problem year negative year out disabled test.
aTestTime5 = floor 1407182031000.0 -- 2014-08-04T19:53:51.000Z

formatTest _ =
  suite "format tests" <|
    List.map runFormatTest formatTestCases


-- forces to +10:00 time zone so will run on any time zone
runFormatTest (name, expected, formatStr, time) =
  test name <|
    assertEqual
      expected
      (Format.formatOffset Config_en_us.config -600 formatStr (Core.fromTime time))


_ = Debug.log("asdfasdf 1") Config_en_us.config
c = Config_en_us.config
_ = Debug.log("asdfasdf 2") c.format
_ = Debug.log("asdfasdf 3") (.format Config_en_us.config)
_ = Debug.log("asdfasdf 4") (.format (Config_en_us.config) )
_ = Debug.log("4a") (.date (.format (Config_en_us.config)))
-- _ = Debug.log("4b") (Config_en_us.config.format.date)  -- THIS IS WHACK.
-- d = Config_en_us.config.format.date
-- _ = Debug.log("asdfasdf 5") d


formatTestCases =
  [ ("numeric date", "12/08/2014", "%d/%m/%Y", aTestTime)
  , ("spelled out date", "Tuesday, August 12, 2014", "%A, %B %d, %Y", aTestTime)
  , ("with %% ", "% 12/08/2014", "%% %d/%m/%Y", aTestTime)
  , ("with %% no space", " %12/08/2014", " %%%d/%m/%Y", aTestTime)
  , ("with milliseconds", "2014-08-12 (.116)", "%Y-%m-%d (.%L)", aTestTime)
  , ("with milliseconds", "2014-08-12T18:53:51.116", "%Y-%m-%dT%H:%M:%S.%L", aTestTime)
  , ("small year", "0448-09-09T22:39:28.884", "%Y-%m-%dT%H:%M:%S.%L", aTestTime3)

  , ("Config_en_us date", "8/5/2014", (.date (.format (Config_en_us.config))), aTestTime5)
  , ("Config_en_us longDate", "Tuesday, August 05, 2014", (.longDate (.format (Config_en_us.config))), aTestTime5)
  , ("Config_en_us time", "5:53 AM", (.time (.format (Config_en_us.config))), aTestTime5)
  , ("Config_en_us longTime", "5:53:51 AM", (.longTime (.format (Config_en_us.config))), aTestTime5)
  , ("Config_en_us dateTime", "8/5/2014 5:53 AM", (.dateTime (.format (Config_en_us.config))), aTestTime5)

  , ("Config_en_au date", "5/08/2014", (.date (.format (Config_en_au.config))), aTestTime5)
  , ("Config_en_au longDate", "Tuesday, 5 August 2014", (.longDate (.format (Config_en_au.config))), aTestTime5)
  , ("Config_en_au time", "5:53 AM", (.time (.format (Config_en_au.config))), aTestTime5)
  , ("Config_en_au longTime", "5:53:51 AM", (.longTime (.format (Config_en_au.config))), aTestTime5)
  , ("Config_en_au dateTime", "5/08/2014 5:53 AM", (.dateTime (.format (Config_en_au.config))), aTestTime5)

  -- , ("Config_en_us date", "x", Config_en_us.config.format.date, aTestTime)
  -- , ("small year", "0448-09-09T22:39:28.885", "%Y-%m-%dT%H:%M:%S.%L", aTestTime4)
  ]


formatUtcTest _ =
  suite "formatUtc tests" <|
    List.map runFormatUtcTest formatUtcTestCases


runFormatUtcTest (name, expected, formatStr, time) =
  test name <|
    assertEqual
      expected
      (Format.formatUtc Config_en_us.config formatStr (Core.fromTime time))


formatUtcTestCases =
  [ ( "get back expected date in utc +00:00", "2014-08-12T08:53:51.116+00:00"
    , "%Y-%m-%dT%H:%M:%S.%L%:z", aTestTime
    )
  ]


formatOffsetTest _ =
  suite "formatOffset tests" <|
    List.map runformatOffsetTest formatOffsetTestCases


runformatOffsetTest (name, expected, formatStr, time, offset) =
  test name <|
    assertEqual
      expected
      (Format.formatOffset Config_en_us.config offset formatStr (Core.fromTime time))


formatOffsetTestCases =
  [ ( "get back expected date in utc -04:00", "2014-08-12T04:53:51.116-04:00"
    , "%Y-%m-%dT%H:%M:%S.%L%:z", aTestTime, 240
    )
  , ( "get back expected date in utc -12:00", "2014-08-12T20:53:51.116+12:00"
    , "%Y-%m-%dT%H:%M:%S.%L%:z", aTestTime, -720
    )
  , ( "12 hour time %I", "Wednesday, 13 August 2014 12:53:51 AM"
    , "%A, %e %B %Y %I:%M:%S %p"
    , aTestTime2, -600
    )
  , ( "12 hour time %l", "Wednesday, 13 August 2014 12:53:51 AM"
    , "%A, %e %B %Y %l:%M:%S %p"
    , aTestTime2, -600
    )
  ]

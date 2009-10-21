        !COMPILER-GENERATED INTERFACE MODULE: Mon Jul 13 12:13:45 2009
        MODULE LOAD_SPE_mod
          INTERFACE 
            SUBROUTINE LOAD_SPE(NDET,NE,DATA_S,DATA_ERR,DATA_EN,FILENAME&
     &)
              INTEGER(KIND=4) :: NE
              INTEGER(KIND=4) :: NDET
              REAL(KIND=8) :: DATA_S(NE,NDET)
              REAL(KIND=8) :: DATA_ERR(NE,NDET)
              REAL(KIND=8) :: DATA_EN(NE+1)
              CHARACTER(*) :: FILENAME
            END SUBROUTINE LOAD_SPE
          END INTERFACE 
        END MODULE LOAD_SPE_mod

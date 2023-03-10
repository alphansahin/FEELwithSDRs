-- -------------------------------------------------------------
-- 
-- File Name: hdl_prj\hdlsrc\SDRIP\SDRIPDUT_ip_src_Detector.vhd
-- Created: 2022-06-06 21:52:42
-- 
-- Generated by MATLAB 9.12 and HDL Coder 3.20
-- 
-- -------------------------------------------------------------


-- -------------------------------------------------------------
-- 
-- Module: SDRIPDUT_ip_src_Detector
-- Source Path: SDRIP/SDR IP DUT/Detector
-- Hierarchy Level: 1
-- 
-- -------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.SDRIPDUT_ip_src_SDR_IP_DUT_pkg.ALL;

ENTITY SDRIPDUT_ip_src_Detector IS
  PORT( clk                               :   IN    std_logic;
        reset                             :   IN    std_logic;
        enb                               :   IN    std_logic;
        xcorrSquareIn                     :   IN    std_logic_vector(36 DOWNTO 0);  -- ufix37
        acorrSquareIn                     :   IN    std_logic_vector(30 DOWNTO 0);  -- ufix31
        enableIn                          :   IN    std_logic;
        detectedRepeat                    :   OUT   std_logic;
        detectorCntSingle                 :   OUT   std_logic_vector(31 DOWNTO 0)  -- uint32
        );
END SDRIPDUT_ip_src_Detector;


ARCHITECTURE rtl OF SDRIPDUT_ip_src_Detector IS

  -- Functions
  -- HDLCODER_TO_STDLOGIC 
  FUNCTION hdlcoder_to_stdlogic(arg: boolean) RETURN std_logic IS
  BEGIN
    IF arg THEN
      RETURN '1';
    ELSE
      RETURN '0';
    END IF;
  END FUNCTION;


  -- Signals
  SIGNAL xcorrSquareIn_unsigned           : unsigned(36 DOWNTO 0);  -- ufix37
  SIGNAL acorrSquareIn_unsigned           : unsigned(30 DOWNTO 0);  -- ufix31
  SIGNAL detectorCntSingle_tmp            : unsigned(31 DOWNTO 0);  -- uint32
  SIGNAL detectionHistory                 : std_logic_vector(0 TO 192);  -- ufix1 [193]
  SIGNAL detectorCntSingle_reg            : unsigned(31 DOWNTO 0);  -- uint32
  SIGNAL detectionHistory_next            : std_logic_vector(0 TO 192);  -- ufix1 [193]
  SIGNAL detectorCntSingle_reg_next       : unsigned(31 DOWNTO 0);  -- uint32

BEGIN
  xcorrSquareIn_unsigned <= unsigned(xcorrSquareIn);

  acorrSquareIn_unsigned <= unsigned(acorrSquareIn);

  Detector_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF reset = '1' THEN
        detectionHistory <= (OTHERS => '0');
        detectorCntSingle_reg <= to_unsigned(16#00000000#, 32);
      ELSIF enb = '1' THEN
        detectionHistory <= detectionHistory_next;
        detectorCntSingle_reg <= detectorCntSingle_reg_next;
      END IF;
    END IF;
  END PROCESS Detector_process;

  Detector_output : PROCESS (acorrSquareIn_unsigned, detectionHistory, detectorCntSingle_reg, enableIn,
       xcorrSquareIn_unsigned)
    VARIABLE detectedRepeat1 : std_logic;
    VARIABLE detected : std_logic;
    VARIABLE c : unsigned(36 DOWNTO 0);
    VARIABLE cast : vector_of_signed64(0 TO 3);
  BEGIN
    detectionHistory_next <= detectionHistory;
    detectorCntSingle_reg_next <= detectorCntSingle_reg;
    c := SHIFT_RIGHT(xcorrSquareIn_unsigned, 4);
    detected := hdlcoder_to_stdlogic(c > resize(acorrSquareIn_unsigned, 37));
    detectedRepeat1 := '1';

    FOR k IN 0 TO 3 LOOP
      cast(k) := resize(to_signed(k, 32) & '0' & '0' & '0' & '0' & '0' & '0', 64);
      detectedRepeat1 := detectedRepeat1 AND detectionHistory(to_integer(resize(cast(k), 31)));
    END LOOP;

    IF enableIn = '1' THEN 
      IF detected = '1' THEN 
        detectorCntSingle_reg_next <= detectorCntSingle_reg + 1;
      END IF;
      detectionHistory_next(0) <= detected;
      detectionHistory_next(1 TO 192) <= detectionHistory(0 TO 191);
    END IF;
    detectedRepeat <= detectedRepeat1;
    detectorCntSingle_tmp <= detectorCntSingle_reg;
  END PROCESS Detector_output;


  detectorCntSingle <= std_logic_vector(detectorCntSingle_tmp);

END rtl;


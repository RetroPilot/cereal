using Cxx = import "./include/c++.capnp";
$Cxx.namespace("cereal");

using Java = import "./include/java.capnp";
$Java.package("ai.comma.openpilot.cereal");
$Java.outerClassname("Car");

@0x8e2af1e708af8b8d;

# ******* events causing controls state machine transition *******

struct CarEvent @0x9b1657f34caf3ad3 {
  name @0 :EventName;

  # event types
  enable @1 :Bool;
  noEntry @2 :Bool;
  warning @3 :Bool;   # alerts presented only when  enabled or soft disabling
  userDisable @4 :Bool;
  softDisable @5 :Bool;
  immediateDisable @6 :Bool;
  preEnable @7 :Bool;
  permanent @8 :Bool; # alerts presented regardless of openpilot state

  enum EventName @0xbaa8c5d505f727de {
    canError @0;
    steerUnavailable @1;
    brakeUnavailable @2;
    wrongGear @4;
    doorOpen @5;
    seatbeltNotLatched @6;
    espDisabled @7;
    wrongCarMode @8;
    steerTempUnavailable @9;
    reverseGear @10;
    buttonCancel @11;
    buttonEnable @12;
    pedalPressed @13;
    cruiseDisabled @14;
    speedTooLow @17;
    outOfSpace @18;
    overheat @19;
    calibrationIncomplete @20;
    calibrationInvalid @21;
    controlsMismatch @22;
    pcmEnable @23;
    pcmDisable @24;
    noTarget @25;
    radarFault @26;
    brakeHold @28;
    parkBrake @29;
    manualRestart @30;
    lowSpeedLockout @31;
    plannerError @32;
    debugAlert @34;
    steerTempUnavailableUserOverride @35;
    resumeRequired @36;
    preDriverDistracted @37;
    promptDriverDistracted @38;
    driverDistracted @39;
    preDriverUnresponsive @43;
    promptDriverUnresponsive @44;
    driverUnresponsive @45;
    belowSteerSpeed @46;
    lowBattery @48;
    vehicleModelInvalid @50;
    accFaulted @51;
    sensorDataInvalid @52;
    commIssue @53;
    tooDistracted @54;
    posenetInvalid @55;
    soundsUnavailable @56;
    preLaneChangeLeft @57;
    preLaneChangeRight @58;
    laneChange @59;
    communityFeatureDisallowed @62;
    lowMemory @63;
    stockAeb @64;
    ldw @65;
    carUnrecognized @66;
    driverMonitorLowAcc @68;
    invalidLkasSetting @69;
    speedTooHigh @70;
    laneChangeBlocked @71;
    relayMalfunction @72;
    gasPressed @73;
    stockFcw @74;
    startup @75;
    startupNoCar @76;
    startupNoControl @77;
    startupMaster @78;
    startupFuzzyFingerprint @97;
    fcw @79;
    steerSaturated @80;
    belowEngageSpeed @84;
    noGps @85;
    wrongCruiseMode @87;
    modeldLagging @89;
    deviceFalling @90;
    fanMalfunction @91;
    cameraMalfunction @92;
    gpsMalfunction @94;
    processNotRunning @95;
    dashcamMode @96;
    controlsInitializing @98;
    usbError @99;

    radarCanErrorDEPRECATED @15;
    radarCommIssueDEPRECATED @67;
    gasUnavailableDEPRECATED @3;
    dataNeededDEPRECATED @16;
    modelCommIssueDEPRECATED @27;
    ipasOverrideDEPRECATED @33;
    geofenceDEPRECATED @40;
    driverMonitorOnDEPRECATED @41;
    driverMonitorOffDEPRECATED @42;
    calibrationProgressDEPRECATED @47;
    invalidGiraffeHondaDEPRECATED @49;
    invalidGiraffeToyotaDEPRECATED @60;
    internetConnectivityNeededDEPRECATED @61;
    whitePandaUnsupportedDEPRECATED @81;
    commIssueWarningDEPRECATED @83;
    focusRecoverActiveDEPRECATED @86;
    neosUpdateRequiredDEPRECATED @88;
    modelLagWarningDEPRECATED @93;
    startupOneplusDEPRECATED @82;
  }
}

# ******* main car state @ 100hz *******
# all speeds in m/s

struct CarState {
  events @13 :List(CarEvent);

  # car speed
  vEgo @1 :Float32;         # best estimate of speed
  aEgo @16 :Float32;        # best estimate of acceleration
  vEgoRaw @17 :Float32;     # unfiltered speed from CAN sensors
  yawRate @22 :Float32;     # best estimate of yaw rate
  standstill @18 :Bool;
  wheelSpeeds @2 :WheelSpeeds;

  # gas pedal, 0.0-1.0
  gas @3 :Float32;        # this is user + computer
  gasPressed @4 :Bool;    # this is user pedal only

  # brake pedal, 0.0-1.0
  brake @5 :Float32;      # this is user pedal only
  brakePressed @6 :Bool;  # this is user pedal only
  brakeLights @19 :Bool;

  # steering wheel
  steeringAngleDeg @7 :Float32;
  steeringRateDeg @15 :Float32;
  steeringTorque @8 :Float32;      # TODO: standardize units
  steeringTorqueEps @27 :Float32;  # TODO: standardize units
  steeringPressed @9 :Bool;        # if the user is using the steering wheel
  steeringRateLimited @29 :Bool;   # if the torque is limited by the rate limiter
  steerWarning @35 :Bool;          # temporary steer unavailble
  steerError @36 :Bool;            # permanent steer error
  stockAeb @30 :Bool;
  stockFcw @31 :Bool;
  espDisabled @32 :Bool;

  # cruise state
  cruiseState @10 :CruiseState;

  # gear
  gearShifter @14 :GearShifter;

  # button presses
  buttonEvents @11 :List(ButtonEvent);
  leftBlinker @20 :Bool;
  rightBlinker @21 :Bool;
  genericToggle @23 :Bool;

  # lock info
  doorOpen @24 :Bool;
  seatbeltUnlatched @25 :Bool;
  canValid @26 :Bool;

  # clutch (manual transmission only)
  clutchPressed @28 :Bool;

  # which packets this state came from
  canMonoTimes @12: List(UInt64);

  # blindspot sensors
  leftBlindspot @33 :Bool; # Is there something blocking the left lane change
  rightBlindspot @34 :Bool; # Is there something blocking the right lane change

  struct WheelSpeeds {
    # optional wheel speeds
    fl @0 :Float32;
    fr @1 :Float32;
    rl @2 :Float32;
    rr @3 :Float32;
  }

  struct CruiseState {
    enabled @0 :Bool;
    speed @1 :Float32;
    available @2 :Bool;
    speedOffset @3 :Float32;
    standstill @4 :Bool;
    nonAdaptive @5 :Bool;
  }

  enum GearShifter {
    unknown @0;
    park @1;
    drive @2;
    neutral @3;
    reverse @4;
    sport @5;
    low @6;
    brake @7;
    eco @8;
    manumatic @9;
  }

  # send on change
  struct ButtonEvent {
    pressed @0 :Bool;
    type @1 :Type;

    enum Type {
      unknown @0;
      leftBlinker @1;
      rightBlinker @2;
      accelCruise @3;
      decelCruise @4;
      cancel @5;
      altButton1 @6;
      altButton2 @7;
      altButton3 @8;
      setCruise @9;
      resumeCruise @10;
      gapAdjustCruise @11;
    }
  }

  errorsDEPRECATED @0 :List(CarEvent.EventName);
}

# ******* radar state @ 20hz *******

struct RadarData @0x888ad6581cf0aacb {
  errors @0 :List(Error);
  points @1 :List(RadarPoint);

  # which packets this state came from
  canMonoTimes @2 :List(UInt64);

  enum Error {
    canError @0;
    fault @1;
    wrongConfig @2;
  }

  # similar to LiveTracks
  # is one timestamp valid for all? I think so
  struct RadarPoint {
    trackId @0 :UInt64;  # no trackId reuse

    # these 3 are the minimum required
    dRel @1 :Float32; # m from the front bumper of the car
    yRel @2 :Float32; # m
    vRel @3 :Float32; # m/s

    # these are optional and valid if they are not NaN
    aRel @4 :Float32; # m/s^2
    yvRel @5 :Float32; # m/s

    # some radars flag measurements VS estimates
    measured @6 :Bool;
  }
}

# ******* car controls @ 100hz *******

struct CarControl {
  # must be true for any actuator commands to work
  enabled @0 :Bool;
  active @7 :Bool;

  actuators @6 :Actuators;
  bodycontrol @8 :BodyControl;

  cruiseControl @4 :CruiseControl;
  hudControl @5 :HUDControl;

  struct Actuators {
    # range from 0.0 - 1.0
    gas @0: Float32;
    brake @1: Float32;
    # range from -1.0 - 1.0
    steer @2: Float32;
    steeringAngleDeg @3: Float32;
  }

  struct BodyControl {
    # raw binary control for 8 relays
    relayCoreCMD @0: UInt8;
  }

  struct CruiseControl {
    cancel @0: Bool;
    override @1: Bool;
    speedOverride @2: Float32;
    accelOverride @3: Float32;
  }

  struct HUDControl {
    speedVisible @0: Bool;
    setSpeed @1: Float32;
    lanesVisible @2: Bool;
    leadVisible @3: Bool;
    visualAlert @4: VisualAlert;
    audibleAlert @5: AudibleAlert;
    rightLaneVisible @6: Bool;
    leftLaneVisible @7: Bool;
    rightLaneDepart @8: Bool;
    leftLaneDepart @9: Bool;

    enum VisualAlert {
      # these are the choices from the Honda
      # map as good as you can for your car
      none @0;
      fcw @1;
      steerRequired @2;
      brakePressed @3;
      wrongGear @4;
      seatbeltUnbuckled @5;
      speedTooHigh @6;
      ldw @7;
    }

    enum AudibleAlert {
      none @0;
      chimeEngage @1;
      chimeDisengage @2;
      chimeError @3;
      chimeWarning1 @4;
      chimeWarning2 @5;
      chimeWarningRepeat @6;
      chimePrompt @7;
      chimeWarning2Repeat @8;
    }
  }

  gasDEPRECATED @1 :Float32;
  brakeDEPRECATED @2 :Float32;
  steeringTorqueDEPRECATED @3 :Float32;
}

# ****** car param ******

struct CarParams {
  carName @0 :Text;
  carFingerprint @1 :Text;
  fuzzyFingerprint @55 :Bool;

  enableGasInterceptor @2 :Bool;
  enableGasActuator @57 :Bool;
  enableSteerInterceptor @58 :Bool;
  enableSteerActuator @59 :Bool;
  enableiBooster @60 :Bool;

  enableCruise @3 :Bool;
  enableCamera @4 :Bool;
  enableDsu @5 :Bool; # driving support unit
  enableApgs @6 :Bool; # advanced parking guidance system
  enableBsm @56 :Bool; # blind spot monitoring

  minEnableSpeed @7 :Float32;
  minSteerSpeed @8 :Float32;
  maxSteeringAngleDeg @54 :Float32;
  safetyModel @9 :SafetyModel;
  safetyModelPassive @42 :SafetyModel = silent;
  safetyParam @10 :Int16;

  steerMaxBP @11 :List(Float32);
  steerMaxV @12 :List(Float32);
  gasMaxBP @13 :List(Float32);
  gasMaxV @14 :List(Float32);
  brakeMaxBP @15 :List(Float32);
  brakeMaxV @16 :List(Float32);

  # things about the car in the manual
  mass @17 :Float32;            # [kg] curb weight: all fluids no cargo
  wheelbase @18 :Float32;       # [m] distance from rear axle to front axle
  centerToFront @19 :Float32;   # [m] distance from center of mass to front axle
  steerRatio @20 :Float32;      # [] ratio of steering wheel angle to front wheel angle
  steerRatioRear @21 :Float32;  # [] ratio of steering wheel angle to rear wheel angle (usually 0)

  # things we can derive
  rotationalInertia @22 :Float32;    # [kg*m2] body rotational inertia
  tireStiffnessFront @23 :Float32;   # [N/rad] front tire coeff of stiff
  tireStiffnessRear @24 :Float32;    # [N/rad] rear tire coeff of stiff

  longitudinalTuning @25 :LongitudinalPIDTuning;
  lateralParams @48 :LateralParams;
  lateralTuning :union {
    pid @26 :LateralPIDTuning;
    indi @27 :LateralINDITuning;
    lqr @40 :LateralLQRTuning;
  }

  steerLimitAlert @28 :Bool;
  steerLimitTimer @47 :Float32;  # time before steerLimitAlert is issued

  vEgoStopping @29 :Float32; # Speed at which the car goes into stopping state
  directAccelControl @30 :Bool; # Does the car have direct accel control or just gas/brake
  stoppingControl @31 :Bool; # Does the car allows full control even at lows speeds when stopping
  startAccel @32 :Float32; # Required acceleraton to overcome creep braking
  steerRateCost @33 :Float32; # Lateral MPC cost on steering rate
  steerControlType @34 :SteerControlType;
  radarOffCan @35 :Bool; # True when radar objects aren't visible on CAN
  minSpeedCan @51 :Float32; # Minimum vehicle speed from CAN (below this value drops to 0)
  stoppingBrakeRate @52 :Float32; # brake_travel/s while trying to stop
  startingBrakeRate @53 :Float32; # brake_travel/s while releasing on restart

  steerActuatorDelay @36 :Float32; # Steering wheel actuator delay in seconds
  openpilotLongitudinalControl @37 :Bool; # is openpilot doing the longitudinal control?
  carVin @38 :Text; # VIN number queried during fingerprinting
  dashcamOnly @41: Bool;
  transmissionType @43 :TransmissionType;
  carFw @44 :List(CarFw);

  radarTimeStep @45: Float32 = 0.05;  # time delta between radar updates, 20Hz is very standard
  communityFeature @46: Bool;  # true if a community maintained feature is detected
  fingerprintSource @49: FingerprintSource;
  networkLocation @50 :NetworkLocation;  # Where Panda/C2 is integrated into the car's CAN network

  struct LateralParams {
    torqueBP @0 :List(Int32);
    torqueV @1 :List(Int32);
  }

  struct LateralPIDTuning {
    kpBP @0 :List(Float32);
    kpV @1 :List(Float32);
    kiBP @2 :List(Float32);
    kiV @3 :List(Float32);
    kf @4 :Float32;
  }

  struct LongitudinalPIDTuning {
    kpBP @0 :List(Float32);
    kpV @1 :List(Float32);
    kiBP @2 :List(Float32);
    kiV @3 :List(Float32);
    deadzoneBP @4 :List(Float32);
    deadzoneV @5 :List(Float32);
  }

  struct LateralINDITuning {
    outerLoopGainBP @4 :List(Float32);
    outerLoopGainV @5 :List(Float32);
    innerLoopGainBP @6 :List(Float32);
    innerLoopGainV @7 :List(Float32);
    timeConstantBP @8 :List(Float32);
    timeConstantV @9 :List(Float32);
    actuatorEffectivenessBP @10 :List(Float32);
    actuatorEffectivenessV @11 :List(Float32);

    outerLoopGainDEPRECATED @0 :Float32;
    innerLoopGainDEPRECATED @1 :Float32;
    timeConstantDEPRECATED @2 :Float32;
    actuatorEffectivenessDEPRECATED @3 :Float32;
  }

  struct LateralLQRTuning {
    scale @0 :Float32;
    ki @1 :Float32;
    dcGain @2 :Float32;

    # State space system
    a @3 :List(Float32);
    b @4 :List(Float32);
    c @5 :List(Float32);

    k @6 :List(Float32);  # LQR gain
    l @7 :List(Float32);  # Kalman gain
  }

  enum SafetyModel {
    silent @0;
    hondaNidec @1;
    toyota @2;
    elm327 @3;
    gm @4;
    hondaBoschGiraffe @5;
    ford @6;
    cadillac @7;
    hyundai @8;
    chrysler @9;
    tesla @10;
    subaru @11;
    gmPassive @12;
    mazda @13;
    nissan @14;
    volkswagen @15;
    toyotaIpas @16;
    allOutput @17;
    gmAscm @18;
    noOutput @19;  # like silent but without silent CAN TXs
    hondaBoschHarness @20;
    volkswagenPq @21;
    subaruLegacy @22;  # pre-Global platform
    hyundaiLegacy @23;
    hyundaiCommunity @24;
    ocelot @25;
  }

  enum SteerControlType {
    torque @0;
    angle @1;
  }

  enum TransmissionType {
    unknown @0;
    automatic @1;  # Traditional auto, including DSG
    manual @2;  # True "stick shift" only
    direct @3;  # Electric vehicle or other direct drive
  }

  struct CarFw {
    ecu @0 :Ecu;
    fwVersion @1 :Data;
    address @2: UInt32;
    subAddress @3: UInt8;
  }

  enum Ecu {
    eps @0;
    esp @1;
    fwdRadar @2;
    fwdCamera @3;
    engine @4;
    unknown @5;
    transmission @8; # Transmission Control Module
    srs @9; # airbag
    gateway @10; # can gateway
    hud @11; # heads up display
    combinationMeter @12; # instrument cluster

    # Toyota only
    dsu @6;
    apgs @7;

    # Honda only
    vsa @13; # Vehicle Stability Assist
    programmedFuelInjection @14;
    electricBrakeBooster @15;
    shiftByWire @16;
  }

  enum FingerprintSource {
    can @0;
    fw @1;
    fixed @2;
  }

  enum NetworkLocation {
    fwdCamera @0;  # Standard/default integration at LKAS camera
    gateway @1;    # Integration at vehicle's CAN gateway
  }

  isPandaBlackDEPRECATED @39: Bool;
}

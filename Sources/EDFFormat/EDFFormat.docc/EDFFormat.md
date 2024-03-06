# ``EDFFormat``

EDF and BDF data format.

## Overview

This package provides support for the [European Data Format](https://www.edfplus.info) (EDF)
and the [BioSemi Data Format](https://www.biosemi.com/faq/file_format.htm) (BDF).
This library supports [EDF+](https://www.edfplus.info/specs/edfplus.html) by default.

## Topics

### File Writer

- ``EDFFileWriter``
- ``BDFFileWriter``
- ``GenericFileWriter``
- ``EDFEncodingError``
- ``FileFormat``
- ``EDFRecordsFormat``

### Describing a recording

- ``FileInformation``
- ``RecordingIdentification``
- ``RecordingInformation``
- ``SubjectIdentification``
- ``PatientInformation``
- ``Signal``
- ``SignalLabel``
- ``SignalType``

### Data Records

- ``DataRecord``
- ``Channel``
- ``Sample``
- ``EDFSample``
- ``BDFSample``
- ``EEGLocation``

### Dimension

- ``DimensionPrefix``
- ``AngleDimension``
- ``SoundPressureLevelDimension``
- ``TemperatureDimension``

# What are Generators?
**PARKED FOR VERSION 2.0 TARGETING**

Any time a mark is created in OneBrush, an active generator modifier receives a notification including:
- The event that caused the creation of the mark
- The stroke that the mark was created in which includes the list of marks (the last of which, as a value type, is the last one created.)

A Generator does not modify the mark that OneBrush self-created. The task of a Generator is to "do something interesting" in Addition to what OneBrush has done. This is done by contract with OneBrush as a `request` sent back, one request per instance generated. OneBrush may then discard any results received, include them as marks in the self-owned Stroke, or make an entirely new Stroke as a result.

## Radial Symmetry

## Scribble

## 
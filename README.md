# Mobster
*A vertex manipulation toolset for OneBrush*

## Purpose

Documents in OneBrush are made up of renderable "nodes" in an ECS implementation that culminate in Layers that contain Strokes populated with Points.

These Points are the subject of this package's domain. Any Layer in OneBrush can have a series of Modifiers attached to them. These Modifiers alter the painting experience by providing alterations of two distinct types:

- Derived Point Creation
- Applied Point Manipulation

Mobster serves both of these needs by providing "Modifier" types that are configured and consumed by OneBrush.

## Requirements

See [Mobster Design Document](./Documentation/Design/Mobster.md)
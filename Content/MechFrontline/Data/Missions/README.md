# Mission data assets

Create `UMFMissionDefinition` assets here. Example first mission:

- `DA_Mission_SandboxSweep`
  - MissionId: `M_SandboxSweep`
  - One required objective: DestroyTarget, TargetTag `MissionPrimary`
  - MissionMap: `/Game/MechFrontline/Maps/L_DevSandbox`

Tag the primary enemy actor with `MissionPrimary` and call
`UMFMissionSubsystem::CompleteObjective("Obj_DestroyPrimary")` when it dies.

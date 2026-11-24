// Copyright MechFrontline. All rights reserved.

using UnrealBuildTool;
using System.Collections.Generic;

public class MechFrontlineTarget : TargetRules
{
	public MechFrontlineTarget(TargetInfo Target) : base(Target)
	{
		Type = TargetType.Game;
		DefaultBuildSettings = BuildSettingsVersion.V5;
		IncludeOrderVersion = EngineIncludeOrderVersion.Unreal5_5;
		ExtraModuleNames.Add("MechFrontline");
	}
}

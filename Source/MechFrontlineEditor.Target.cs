// Copyright MechFrontline. All rights reserved.

using UnrealBuildTool;
using System.Collections.Generic;

public class MechFrontlineEditorTarget : TargetRules
{
	public MechFrontlineEditorTarget(TargetInfo Target) : base(Target)
	{
		Type = TargetType.Editor;
		DefaultBuildSettings = BuildSettingsVersion.V5;
		IncludeOrderVersion = EngineIncludeOrderVersion.Unreal5_5;
		ExtraModuleNames.Add("MechFrontline");
	}
}

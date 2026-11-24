// Copyright MechFrontline. All rights reserved.

#include "UI/MFHUDWidget.h"

void UMFHUDWidget::PushFrameStatus(const FMFFrameStatus& Status)
{
	OnFrameStatusUpdated(Status);
}

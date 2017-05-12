class X2Effect_ControlledDetonation extends XMBEffect_Extended;

function OnPostTemplatesCreated()
{
	local X2AbilityTemplate AbilityTemplate;
	local X2AbilityTemplateManager AbilityMgr;

	AbilityMgr = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
	AbilityTemplate = AbilityMgr.FindAbilityTemplate('ThrowGrenade');
	AbilityTemplate.AbilityMultiTargetConditions.AddItem(new class'X2Condition_ControlledDetonation');
	AbilityTemplate = AbilityMgr.FindAbilityTemplate('LaunchGrenade');
	AbilityTemplate.AbilityMultiTargetConditions.AddItem(new class'X2Condition_ControlledDetonation');
}

function bool GetExtValue(LWTuple Data) 
{
	local XComGameState_Ability AbilityState;

	if (Data.Id == 'IgnoreFriendlyFire')
	{
		AbilityState = XComGameState_Ability(Data.Data[0].o);

		`Log("X2Effect_ControlledDetonation: Checking for friendly fire on" @ AbilityState.GetMyTemplateName());

		if (AbilityState.GetMyTemplateName() == 'ThrowGrenade' || AbilityState.GetMyTemplateName() == 'LaunchGrenade')
		{
			Data.Data[0].Kind = LWTVBool;
			Data.Data[0].b = true;
			return true;
		}
		else
			return false;
	}

	return super.GetExtValue(Data); 
}
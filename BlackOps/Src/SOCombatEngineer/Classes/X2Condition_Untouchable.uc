class X2Condition_Untouchable extends X2Condition;

struct CheckValue
{
	var CheckConfig     ConfigValue;
	var name            OptionalOverrideFalureCode;
};
var CheckValue mCheckValue;

function AddCheckValue(int Value, optional EValueCheck CheckType=eCheck_Exact, optional int ValueMax=0, optional int ValueMin=0, optional name OptionalOverrideFalureCode='')
{
	mCheckValue.ConfigValue.CheckType = CheckType;
	mCheckValue.ConfigValue.Value = Value;
	mCheckValue.ConfigValue.ValueMin = ValueMin;
	mCheckValue.ConfigValue.ValueMax = ValueMax;
	mCheckValue.OptionalOverrideFalureCode = OptionalOverrideFalureCode;
}

event name CallMeetsCondition(XComGameState_BaseObject kTarget)
{
	local XComGameState_Unit UnitState;
	local name RetCode;

	RetCode = 'AA_Success';
	UnitState = XComGameState_Unit(kTarget);
	if (UnitState != none)
	{
		RetCode = PerformValueCheck(UnitState.Untouchable, mCheckValue.ConfigValue);

		if( RetCode != 'AA_Success' && mCheckValue.OptionalOverrideFalureCode != '' )
		{
			RetCode = mCheckValue.OptionalOverrideFalureCode;
		}
	}
	return RetCode;
}
//---------------------------------------------------------------------------------------
//  FILE:    XMBEffectInterface.uc
//  AUTHOR:  xylthixlm
//
//  This file contains internal implementation of XModBase. You don't need to, and
//  shouldn't, use it directly.
//
//  DEPENDENCIES
//
//  This doesn't depend on anything, but the provided functions will not function
//  without the classes in XModBase/Classes/ installed.
//---------------------------------------------------------------------------------------
interface XMBOverrideInterface;

function class GetOverrideBaseClass();
function GetOverrideVersion(out int Major, out int Minor, out int Patch);

function bool GetExtValue(LWTuple Data);
function bool SetExtValue(LWTuple Data);

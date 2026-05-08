this.xcsmask <- this.inherit("scripts/items/helmets/helmet", {
	m = {},
	function create()
	{
		// 必须先呼叫父类的 create，完成底层物理和背包接口的初始化
		this.helmet.create(); 
		
		this.m.ID = "armor.head.xcsmask";
		this.m.Name = "诸行无常面罩";
		this.m.Description = "诸行无常，命运终将如其所必经的那样，步入它的轨迹。";
		
		this.m.ShowOnCharacter = true;
		this.m.HideHair = false; // 戴面罩不脱发
		this.m.HideBeard = true; // 遮挡胡子
		this.m.ReplaceSprite = true;
		
		this.m.Variant = 41; // 28棕色 45红 41一个很帅的面巾
		this.updateVariant();
		
		this.m.ImpactSound = this.Const.Sound.ArmorLeatherImpact;
		this.m.InventorySound = this.Const.Sound.ClothEquip;
		
		this.m.Value = 500;
		this.m.Condition = 265; 
		this.m.ConditionMax = 265;
		this.m.StaminaModifier = 0; 
	}
});
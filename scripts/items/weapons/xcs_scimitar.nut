this.xcs_scimitar <- this.inherit("scripts/items/weapons/weapon", {
	m = {},
	function create()
	{
		this.weapon.create();
		
		// 核心标识，必须独一无二，这是你在开局场景中调用它的凭证
		this.m.ID = "weapon.xcs_scimitar";
		
		// [可修改点] 武器名称与描述
		this.m.Name = "孤狼的杀戮"; 
		this.m.Description = "诸王的王冠已化为尘土，而刽子手的刀刃依然锋利。";
		
		this.m.Categories = "Cleaver, Two-Handed";
		
		// [可修改点] 如果你以后画了专属贴图，在这里改路径。目前暂时复用原版弯刀贴图。
		this.m.IconLarge = "weapons/melee/xcs_two_handed_saif.png";
		this.m.Icon = "weapons/melee/xcs_two_handed_saif_70x70.png";
		
		this.m.SlotType = this.Const.ItemSlot.Mainhand;
		this.m.BlockedSlotType = this.Const.ItemSlot.Offhand;
		this.m.ItemType = this.Const.Items.ItemType.Weapon | this.Const.Items.ItemType.MeleeWeapon | this.Const.Items.ItemType.TwoHanded;
		this.m.IsAgainstShields = true;
		this.m.AddGenericSkill = true;
		this.m.ShowQuiver = false;
		this.m.ShowArmamentIcon = true;
		this.m.ArmamentIcon = "icon_xcstwo_handed_saif_01";
		// icon_xcstwo_handed_saif_01
		// [可修改点] 武器售卖价值（高一点显得有排面）
		this.m.Value = 90000;
		
		// [可修改点] 破盾伤害（原版16，提升到24两下就能劈碎兽人军阀的铁盾）
		this.m.ShieldDamage = 24;
		
		// [可修改点] 耐久度（原版64）
		this.m.Condition = 90.0;
		this.m.ConditionMax = 90.0;
		
		// [可修改点] 装备疲劳惩罚（原版-14，大幅减轻）
		this.m.StaminaModifier = -6;
		
		// [可修改点] 基础伤害（原版 65-85。作为专属武器，数值拉高）
		this.m.RegularDamage = 75;
		this.m.RegularDamageMax = 95;
		
		// [可修改点] 破甲百分比（原版 1.1，提升到1.3即130%）
		this.m.ArmorDamageMult = 1.1;
		
		// [可修改点] 无视护甲直接打血的比例（原版 0.25，即25%。提升到35%刀刀见肉）
		this.m.DirectDamageAdd = 0.15;
		this.m.DirectDamageMult = 0.35;
	}

	function onEquip()
	{
		this.weapon.onEquip();
		
		// 挂载平砍技能 (Cleave)
		local cleave = this.new("scripts/skills/actives/cleave");
		cleave.m.Icon = "skills/active_210.png";
		cleave.m.IconDisabled = "skills/active_210_sw.png";
		cleave.m.Overlay = "active_210";
		// [可修改点] 降低平砍的疲劳消耗（原版15）
		cleave.m.FatigueCost = 10;
		this.addSkill(cleave);
		
		// 挂载斩首技能 (Decapitate - 敌人血越少伤害越高)
		local decapitate = this.new("scripts/skills/actives/decapitate");
		decapitate.m.FatigueCost = 15;
		this.addSkill(decapitate);
		
		local strike = this.new("scripts/skills/actives/strike_skill");
		strike.m.Icon = "skills/active_200.png";
		strike.m.IconDisabled = "skills/active_200_sw.png";
		strike.m.Overlay = "active_200";
		this.addSkill(strike);

		local reap = this.new("scripts/skills/actives/reap_skill");
		reap.m.Icon = "skills/active_201.png";
		reap.m.IconDisabled = "skills/active_201_sw.png";
		reap.m.Overlay = "active_201";
		this.addSkill(reap);

		// // 挂载破盾技能 (Split Shield)
		// local split_shield = this.new("scripts/skills/actives/split_shield");
		// split_shield.m.FatigueCost = 15; 
		// this.addSkill(split_shield);
	}
});
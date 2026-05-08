this.xcs_greatsword <- this.inherit("scripts/items/weapons/weapon", {
	m = {
		StunChance = 0
	},
	function create()
	{
		// 呼叫父类初始化
		this.weapon.create();
		
		// 基础信息修改
		this.m.ID = "weapon.xcs_greatsword"; // 原版: "weapon.greatsword"
		this.m.Name = "转瞬即逝"; // 原版: "Greatsword"
		this.m.Description = "财富转瞬即逝，友人转瞬即逝；亲族转瞬即逝，同袍转瞬即逝。在这片大地的基石之上，一切皆归于虚无。";
		
		// 沿用原版的外观和动作框架
		this.m.Categories = "Sword, Two-Handed";
		this.m.IconLarge = "weapons/melee/sword_two_hand_02.png";
		this.m.Icon = "weapons/melee/sword_two_hand_02_70x70.png";
		this.m.SlotType = this.Const.ItemSlot.Mainhand;
		this.m.BlockedSlotType = this.Const.ItemSlot.Offhand;
		this.m.ItemType = this.Const.Items.ItemType.Weapon | this.Const.Items.ItemType.MeleeWeapon | this.Const.Items.ItemType.TwoHanded;
		this.m.IsAgainstShields = true;
		this.m.IsAoE = true;
		this.m.AddGenericSkill = true;
		this.m.ShowQuiver = false;
		this.m.ShowArmamentIcon = true;
		this.m.ArmamentIcon = "icon_sword_two_handed_02";

		// ==========================================
		// 核心数值强化区域 (附带原版数值对比)
		// ==========================================
		this.m.Value = 3200;                // 原版: 3200 (这么强的武器，身价必须翻倍)
		this.m.ShieldDamage = 24;           // 原版: 16 (劈盾效率大幅提升)
		this.m.Condition = 100.0;           // 原版: 72.0 (耐久度更高，不容易砍卷刃)
		this.m.ConditionMax = 100.0;        // 原版: 72.0
		this.m.StaminaModifier = -12;        // 原版: -12 (重量减轻，拿在手里扣除的疲劳值变少)
		this.m.RegularDamage = 95;         // 原版: 85 (下限伤害暴涨)
		this.m.RegularDamageMax = 110;      // 原版: 100 (上限伤害暴涨，一刀一个小朋友)
		this.m.ArmorDamageMult = 1.0;      // 原版: 1.0 (护甲伤害倍率提升至 125%)
		this.m.DirectDamageMult = 0.30;     // 原版: 0.25 (穿甲直接伤害从 25% 提升到 35%)
		this.m.ChanceToHitHead = 15;        // 原版: 5 (爆头率额外增加 10%)
	}

	function onEquip()
	{
		this.weapon.onEquip();
		// 赋予大剑特有的技能：下劈 (Overhead Strike)
		local skillToAdd = this.new("scripts/skills/actives/overhead_strike");
		skillToAdd.setStunChance(this.m.StunChance);
		this.addSkill(skillToAdd);
		
		// 赋予技能：裂阵 (Split) - 砍两个
		this.addSkill(this.new("scripts/skills/actives/split"));
		
		// 赋予技能：横扫 (Swing) - 砍三个
		this.addSkill(this.new("scripts/skills/actives/swing"));
		
		// 赋予技能：碎盾 (Split Shield)
		local skillToAdd = this.new("scripts/skills/actives/split_shield");
		skillToAdd.setFatigueCost(skillToAdd.getFatigueCostRaw() + 5);
		this.addSkill(skillToAdd);
	}
});
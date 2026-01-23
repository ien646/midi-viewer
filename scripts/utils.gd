class_name Utils

enum Group {
	NEAR = 0,
	MIDDLE = 1,
	FAR = 2
}

static func group_index_tag(index: int) -> String:
	assert(index >= 0 && index <= 2);
	return group_tag(index as Group);

static func group_tag(group: Group) -> String:	
	match group:
		Group.NEAR: return "Near";
		Group.MIDDLE: return "Middle";
		Group.FAR: return "Far";
	return "Invalid group index";

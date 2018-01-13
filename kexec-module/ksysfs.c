#include <linux/kobject.h>
#include <linux/string.h>
#include <linux/sysfs.h>
#include <linux/init.h>

extern struct kimage *kexec_image;
extern struct kimage *kexec_crash_image;
extern size_t vmcoreinfo_max_size;

#define KERNEL_ATTR_RO(_name) \
static struct kobj_attribute _name##_attr = __ATTR_RO(_name)

#define KERNEL_ATTR_RW(_name) \
static struct kobj_attribute _name##_attr = \
	__ATTR(_name, 0644, _name##_show, _name##_store)

static ssize_t kexec_loaded_show(struct kobject *kobj,
				 struct kobj_attribute *attr, char *buf)
{
	return sprintf(buf, "%d\n", !!kexec_image);
}
KERNEL_ATTR_RO(kexec_loaded);

static ssize_t kexec_crash_loaded_show(struct kobject *kobj,
				       struct kobj_attribute *attr, char *buf)
{
	return sprintf(buf, "%d\n", !!kexec_crash_image);
}
KERNEL_ATTR_RO(kexec_crash_loaded);

static ssize_t kexec_crash_size_show(struct kobject *kobj,
				       struct kobj_attribute *attr, char *buf)
{
	return sprintf(buf, "%zu\n", crash_get_memory_size());
}
static ssize_t kexec_crash_size_store(struct kobject *kobj,
				   struct kobj_attribute *attr,
				   const char *buf, size_t count)
{
	unsigned long cnt;
	int ret;

	if (strict_strtoul(buf, 0, &cnt))
		return -EINVAL;

	ret = crash_shrink_memory(cnt);
	return ret < 0 ? ret : count;
}
KERNEL_ATTR_RW(kexec_crash_size);

static ssize_t vmcoreinfo_show(struct kobject *kobj,
			       struct kobj_attribute *attr, char *buf)
{
	return sprintf(buf, "%lx %x\n",
		       paddr_vmcoreinfo_note(),
		       (unsigned int)vmcoreinfo_max_size);
}
KERNEL_ATTR_RO(vmcoreinfo);

static struct attribute * attrs[] = {
	&kexec_loaded_attr.attr,
	&kexec_crash_loaded_attr.attr,
	&kexec_crash_size_attr.attr,
	&vmcoreinfo_attr.attr,
	NULL
};

static struct attribute_group attr_group = {
	.attrs = attrs,
};

static struct kobject *ksysfs_for_kexec;

int ksysfs_init(void)
{
	int error;

    ksysfs_for_kexec = kobject_get(kernel_kobj);

    if (!ksysfs_for_kexec) {
		printk("Kexec: Failed to get kernel sysfs!\n");
		error = -1;
		goto exit;
	}

	error = sysfs_create_group(ksysfs_for_kexec, &attr_group);
	if (error)
		goto exit;

	return 0;

exit:
	return error;
}

int ksysfs_exit(void)
{
	int error;

    ksysfs_for_kexec = kobject_get(kernel_kobj);

    if (!ksysfs_for_kexec) {
		printk("Kexec: Failed to get kernel sysfs!\n");
		error = -1;
		goto exit;
	}

	sysfs_remove_group(ksysfs_for_kexec, &attr_group);

	return 0;

exit:
	return error;
}





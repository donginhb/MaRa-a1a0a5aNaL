/*
 ***************************************************************************
 * Ralink Tech Inc.
 * 4F, No. 2 Technology 5th Rd.
 * Science-based Industrial Park
 * Hsin-chu, Taiwan, R.O.C.
 *
 * (c) Copyright, Ralink Technology, Inc.
 *
 * All rights reserved. Ralink's source code is an unpublished work and the
 * use of a copyright notice does not imply otherwise. This source code
 * contains confidential trade secret material of Ralink Tech. Any attemp
 * or participation in deciphering, decoding, reverse engineering or in any
 * way altering the source code is stricitly prohibited, unless the prior
 * written consent of Ralink Technology, Inc. is obtained.
 ***************************************************************************
 *
 * $Id: ralink_gpio.c,v 1.9 2008-08-15 11:22:57 steven Exp $
 */
#include <linux/init.h>
#include <linux/version.h>
#include <linux/module.h>
#include <linux/config.h>
#include <linux/kernel.h>
#include <linux/interrupt.h>
#include <linux/fs.h>
#include <linux/workqueue.h>
#ifdef CONFIG_RALINK_GPIO_LED
#include <linux/timer.h>
#endif
#include <asm/uaccess.h>
#include "ralink_gpio.h"
#include <asm/rt2880/surfboardint.h>

#ifdef  CONFIG_DEVFS_FS
#include <linux/devfs_fs_kernel.h>
static  devfs_handle_t devfs_handle;
#endif

/* EZP: set button GPIO definitions */
#if defined(CONFIG_AMIT_CDM530AM)
    #define RALINK_GPIO_BUTTON_WPS RALINK_GPIO_18
    #define RALINK_GPIO_BUTTON_RESET RALINK_GPIO_13
#elif defined(CONFIG_AMIT_CDW531AC)
    #define RALINK_GPIO_BUTTON_WPS RALINK_GPIO_10
    #define RALINK_GPIO_BUTTON_RESET RALINK_GPIO_13
#elif defined(CONFIG_AMIT_CDE570) || defined(CONFIG_AMIT_CDE550)
    #define RALINK_GPIO_BUTTON_WPS RALINK_GPIO_10
    #define RALINK_GPIO_BUTTON_RESET RALINK_GPIO_12
#elif defined(CONFIG_BAUDTEC_RA300R1H)
    #warning "BAUDTEC RA300R1H 1Lan 1Wan"
    #define RALINK_GPIO_BUTTON_WPS RALINK_GPIO_0
    #define RALINK_GPIO_BUTTON_RESET RALINK_GPIO_10
    #define RALINK_GPIO_BUTTON_FUNC
    #define RALINK_GPIO_FUNC_PRESS_COUNT   5
    #define RALINK_GPIO_BUTTON_MODE_MID     RALINK_GPIO_17
    #define RALINK_GPIO_BUTTON_MODE_LEFT    RALINK_GPIO_19
    #define RALINK_GPIO_BUTTON_MODE_RIGHT   RALINK_GPIO_18
    #define RALINK_GPIO_BUTTON_FUNC_MASK    (~(RALINK_GPIO_BUTTON_MODE_MID | RALINK_GPIO_BUTTON_MODE_LEFT | RALINK_GPIO_BUTTON_MODE_RIGHT))
#elif defined(CONFIG_BAUDTEC_RA300R4H)
    #warning "BAUDTEC RA300R4H 4Lan 1Wan"
    #define RALINK_GPIO_BUTTON_WPS RALINK_GPIO_0
    #define RALINK_GPIO_BUTTON_WLAN RALINK_GPIO_0
    #define RALINK_GPIO_BUTTON_RESET RALINK_GPIO_10
#elif defined(CONFIG_BAUDTEC_RA300R4G)
    #warning "BAUDTEC RA300R4G 4Lan 1Wan"
    #define RALINK_GPIO_BUTTON_WPS RALINK_GPIO_0
    #define RALINK_GPIO_BUTTON_WLAN RALINK_GPIO_13
    #define RALINK_GPIO_BUTTON_RESET RALINK_GPIO_10
#elif defined(CONFIG_PORAY_R50E)
    #warning "PORAY R50E 1Lan 1Wan"
    /* RALINK_GPIO_10 is power charging */
    #define RALINK_GPIO_BUTTON_WPS RALINK_GPIO_12
    #define RALINK_GPIO_BUTTON_RESET RALINK_GPIO_13
#elif defined(CONFIG_ABOCOM_5205G)
    #warning "ABOCOM 5205G"
    #define RALINK_GPIO_BUTTON_RESET RALINK_GPIO_10
#elif defined(CONFIG_ABOCOM_4615G)
    #warning "ABOCOM 4615G"
    #define RALINK_GPIO_BUTTON_WPS RALINK_GPIO_0
    #define RALINK_GPIO_BUTTON_WLAN RALINK_GPIO_12
    #define RALINK_GPIO_BUTTON_RESET RALINK_GPIO_10
    #define RALINK_GPIO_BUTTON_USB1 RALINK_GPIO_7
    #define RALINK_GPIO_BUTTON_USB2 RALINK_GPIO_11
#else
    #define RALINK_GPIO_BUTTON_WPS RALINK_GPIO_0
    #define RALINK_GPIO_BUTTON_RESET RALINK_GPIO_10
#endif

/* EZP: set button GPIO definitions */

#define NAME			"ralink_gpio"
#define RALINK_GPIO_DEVNAME	"gpio"
int ralink_gpio_major = 252;
u32 ralink_gpio_intp = 0;
int ralink_gpio_irqnum = 0;
u32 ralink_gpio_edge = 0;
int reset_count = 0, reset_push = 0;
int wps_count = 0, wps_push = 0;
int wifi_count = 0, wifi_push = 0;
int combo_push = 0;

ralink_gpio_reg_info ralink_gpio_info[RALINK_GPIO_NUMBER];
extern unsigned long volatile jiffies;
#ifdef CONFIG_RALINK_GPIO_LED
#define RALINK_LED_DEBUG 0
#define RALINK_GPIO_LED_FREQ (HZ/10)
struct timer_list ralink_gpio_led_timer;
ralink_gpio_led_info ralink_gpio_led_data[RALINK_GPIO_NUMBER];
u32 ralink_gpio_led_value = 0;
struct ralink_gpio_led_status_t {
	int ticks;
	unsigned int ons;
	unsigned int offs;
	unsigned int reseting;
	unsigned int times;
} ralink_gpio_led_stat[RALINK_GPIO_NUMBER];
#endif
struct work_button {
    int  button_helper_data;
    struct work_struct button_helper;
}button_data;
extern int call_usermodehelper(char *path, char **argv, char **envp, int wait);
MODULE_DESCRIPTION("Ralink SoC GPIO Driver");
MODULE_AUTHOR("Winfred Lu <winfred_lu@ralinktech.com.tw>");
MODULE_LICENSE("GPL");
ralink_gpio_reg_info info;


int ralink_gpio_ioctl(struct inode *inode, struct file *file, unsigned int req,
		unsigned long arg)
{
	unsigned long idx, tmp;
	ralink_gpio_reg_info info;
#ifdef CONFIG_RALINK_GPIO_LED
	ralink_gpio_led_info led;
#endif

	idx = (req >> RALINK_GPIO_DATA_LEN) & 0xFFL;
	req &= RALINK_GPIO_DATA_MASK;

	switch(req) {
	case EZP_GPIO_SET_DIR:
		*(volatile u32 *)(RALINK_REG_PIODIR) = cpu_to_le32(arg);
		break;
	case EZP_GPIO_SET_DIR_IN:
		tmp = le32_to_cpu(*(volatile u32 *)(RALINK_REG_PIODIR));
		tmp &= ~cpu_to_le32(arg);
		*(volatile u32 *)(RALINK_REG_PIODIR) = tmp;
		break;
	case EZP_GPIO_SET_DIR_OUT:
		tmp = le32_to_cpu(*(volatile u32 *)(RALINK_REG_PIODIR));
		tmp |= cpu_to_le32(arg);
		*(volatile u32 *)(RALINK_REG_PIODIR) = tmp;
		break;
	case EZP_GPIO_READ: //EZP_GPIO_READ_INT
		tmp = le32_to_cpu(*(volatile u32 *)(RALINK_REG_PIODATA));
		put_user(tmp, (int __user *)arg);
		break;
	case EZP_GPIO_WRITE: //EZP_GPIO_WRITE_INT
		*(volatile u32 *)(RALINK_REG_PIODATA) = cpu_to_le32(arg);
		break;
	case EZP_GPIO_SET: //EZP_GPIO_SET_INT
		*(volatile u32 *)(RALINK_REG_PIOSET) = cpu_to_le32(arg);
		break;
	case EZP_GPIO_CLEAR: //EZP_GPIO_CLEAR_INT
		*(volatile u32 *)(RALINK_REG_PIORESET) = cpu_to_le32(arg);
		break;
	case EZP_GPIO_READ_BIT:
		tmp = le32_to_cpu(*(volatile u32 *)(RALINK_REG_PIODATA));
		if (0L <= idx && idx < RALINK_GPIO_DATA_LEN) {
			tmp = (tmp >> idx) & 1L;
			put_user(tmp, (int __user *)arg);
		}
		else
			return -EINVAL;
		break;
	case EZP_GPIO_WRITE_BIT:
		if (0L <= idx && idx < RALINK_GPIO_DATA_LEN) {
			tmp =le32_to_cpu(*(volatile u32 *)(RALINK_REG_PIODATA));
			if (arg & 1L)
				tmp |= (1L << idx);
			else
				tmp &= ~(1L << idx);
			*(volatile u32 *)(RALINK_REG_PIODATA)= cpu_to_le32(tmp);
		}
		else
			return -EINVAL;
		break;
	case EZP_GPIO_READ_BYTE:
		tmp = le32_to_cpu(*(volatile u32 *)(RALINK_REG_PIODATA));
		if (0L <= idx && idx < RALINK_GPIO_DATA_LEN/8) {
			tmp = (tmp >> idx*8) & 0xFFL;
			put_user(tmp, (int __user *)arg);
		}
		else
			return -EINVAL;
		break;
	case EZP_GPIO_WRITE_BYTE:
		if (0L <= idx && idx < RALINK_GPIO_DATA_LEN/8) {
			tmp =le32_to_cpu(*(volatile u32 *)(RALINK_REG_PIODATA));
			tmp &= ~(0xFFL << idx*8);
			tmp |= ((arg & 0xFFL) << idx*8);
			*(volatile u32 *)(RALINK_REG_PIODATA)= cpu_to_le32(tmp);
		}
		else
			return -EINVAL;
		break;
	case EZP_GPIO_ENABLE_INTP:
		*(volatile u32 *)(RALINK_REG_INTENA) = cpu_to_le32(RALINK_INTCTL_PIO);
		break;
	case EZP_GPIO_DISABLE_INTP:
		*(volatile u32 *)(RALINK_REG_INTDIS) = cpu_to_le32(RALINK_INTCTL_PIO);
		break;
	case EZP_GPIO_REG_IRQ:
		copy_from_user(&info, (ralink_gpio_reg_info *)arg, sizeof(info));
		if (0 <= info.irq && info.irq < RALINK_GPIO_NUMBER) {
			ralink_gpio_info[info.irq].pid = info.pid;
			tmp = le32_to_cpu(*(volatile u32 *)(RALINK_REG_PIORENA));
			tmp |= (0x1 << info.irq);
			*(volatile u32 *)(RALINK_REG_PIORENA) = cpu_to_le32(tmp);
			tmp = le32_to_cpu(*(volatile u32 *)(RALINK_REG_PIOFENA));
			tmp |= (0x1 << info.irq);
			*(volatile u32 *)(RALINK_REG_PIOFENA) = cpu_to_le32(tmp);
		}
		else
			printk(KERN_ERR NAME ": irq number(%d) out of range\n",
					info.irq);
		break;
	case EZP_GPIO_LED_SET:
#ifdef CONFIG_RALINK_GPIO_LED
		copy_from_user(&led, (ralink_gpio_led_info *)arg, sizeof(led));
		if (0 <= led.gpio && led.gpio < RALINK_GPIO_NUMBER) {
			if (led.on > RALINK_GPIO_LED_INFINITY)
				led.on = RALINK_GPIO_LED_INFINITY;
			if (led.off > RALINK_GPIO_LED_INFINITY)
				led.off = RALINK_GPIO_LED_INFINITY;
			if (led.blinks > RALINK_GPIO_LED_INFINITY)
				led.blinks = RALINK_GPIO_LED_INFINITY;
			if (led.rests > RALINK_GPIO_LED_INFINITY)
				led.rests = RALINK_GPIO_LED_INFINITY;
			if (led.times > RALINK_GPIO_LED_INFINITY)
				led.times = RALINK_GPIO_LED_INFINITY;
			if (led.on == 0 && led.off == 0 && led.blinks == 0 &&
					led.rests == 0) {
				ralink_gpio_led_data[led.gpio].gpio = -1; //stop it
				break;
			}
			//register led data
			ralink_gpio_led_data[led.gpio].gpio = led.gpio;
			ralink_gpio_led_data[led.gpio].on = led.on;
			ralink_gpio_led_data[led.gpio].off = led.off;
			ralink_gpio_led_data[led.gpio].blinks = led.blinks;
			ralink_gpio_led_data[led.gpio].rests = led.rests;
			ralink_gpio_led_data[led.gpio].times = led.times;

			//clear previous led status
			ralink_gpio_led_stat[led.gpio].ticks = -1;
			ralink_gpio_led_stat[led.gpio].ons = 0;
			ralink_gpio_led_stat[led.gpio].offs = 0;
			ralink_gpio_led_stat[led.gpio].reseting = 0;
			ralink_gpio_led_stat[led.gpio].times = 0;

			//set gpio direction to 'out'
			tmp = le32_to_cpu(*(volatile u32 *)(RALINK_REG_PIODIR));
			tmp |= RALINK_GPIO(led.gpio);
			*(volatile u32 *)(RALINK_REG_PIODIR) = tmp;
#if RALINK_LED_DEBUG
			printk("dir_%x gpio_%d - %d %d %d %d %d\n", tmp,
					led.gpio, led.on, led.off, led.blinks,
					led.rests, led.times);
#endif
		}
		else
			printk(KERN_ERR NAME ": gpio number(%d) out of range\n",
					led.gpio);
#else
		printk(KERN_ERR NAME ": gpio led support not built\n");
#endif
		break;
	default:
		return -ENOIOCTLCMD;
	}
	return 0;
}

int ralink_gpio_open(struct inode *inode, struct file *file)
{
#if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,0)
	MOD_INC_USE_COUNT;
#else
	try_module_get(THIS_MODULE);
#endif
	return 0;
}

int ralink_gpio_release(struct inode *inode, struct file *file)
{
#if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,0)
	MOD_DEC_USE_COUNT;
#else
	module_put(THIS_MODULE);
#endif
	return 0;
}

struct file_operations ralink_gpio_fops =
{
	owner:		THIS_MODULE,
	ioctl:		ralink_gpio_ioctl,
	open:		ralink_gpio_open,
	release:	ralink_gpio_release,
};

#ifdef CONFIG_RALINK_GPIO_LED

#if RALINK_GPIO_LED_LOW_ACT
#define __LED_ON(gpio) ralink_gpio_led_value &= ~RALINK_GPIO(gpio);
#define __LED_OFF(gpio) ralink_gpio_led_value |= RALINK_GPIO(gpio);
#else
#define __LED_ON(gpio) ralink_gpio_led_value |= RALINK_GPIO(gpio);
#define __LED_OFF(gpio) ralink_gpio_led_value &= ~RALINK_GPIO(gpio);
#endif

void button_helper_action(struct work_struct *work)
{
    int retval;
    char *gpio_argv[3];
    static char *gpio_envp[] =
    { "HOME=/", "PATH=/sbin:/usr/sbin:/bin:/usr/bin", NULL };
    struct work_button *button_data = 
        container_of(work, struct work_button, button_helper);
    char function_id[6];

    gpio_argv[0] = "/sbin/ezp-gpio";
    if (button_data->button_helper_data == BUTTON_WPS) {
        printk("WPS button\n");
        gpio_argv[1] = "usb-remove";
        gpio_argv[2] = NULL;
    } else if (button_data->button_helper_data == BUTTON_RESET) {
        printk("Reset button\n");
        gpio_argv[1] = "default";
        gpio_argv[2] = NULL;
    } else if (button_data->button_helper_data == BUTTON_WIFI_ON_OFF) {
        printk("Wifi button\n");
        gpio_argv[1] = "wifi";
        gpio_argv[2] = NULL;
    } else if ((button_data->button_helper_data & 0xff) == BUTTON_FUNC) {
        printk("Function button %d\n", button_data->button_helper_data >> 8);
        snprintf(function_id, sizeof(function_id), "%d", button_data->button_helper_data >> 8);
        gpio_argv[1] = "func";
        gpio_argv[2] = function_id;
        gpio_argv[3] = NULL;
    } else {
        printk("no action!\n");
        return;
    }
    retval = call_usermodehelper(gpio_argv[0], gpio_argv, gpio_envp, 0);
    if (retval) {
        printk("call_usermodehelper retval %d\n", retval);
    }
}

#ifdef RALINK_GPIO_BUTTON_FUNC
static char gpio_func_num = 0, gpio_count = 0, gpio_func_avtivated = 0;
static void ezp_gpio_handle_func_button(unsigned long gpiodata, unsigned long gpiomask) {
    int i;
    /* In this phase, We left WPS and RESET for original use, only 
     * apply to new buttons/switchs. */
    for (i = 0;i < RALINK_GPIO_NUMBER; i++) {
        if (!(gpiomask & RALINK_GPIO(i)) && !(gpiodata & RALINK_GPIO(i)) &&
            (gpiodata & RALINK_GPIO_BUTTON_WPS) && 
            (gpiodata & RALINK_GPIO_BUTTON_RESET)) {
            if (gpio_func_num == i) {
                if (gpio_count < RALINK_GPIO_FUNC_PRESS_COUNT) {
                    gpio_count ++;
                }
                else if (!gpio_func_avtivated){
                    /* Activate action*/
                    button_data.button_helper_data = BUTTON_FUNC | (i << 8);
                    schedule_work(&button_data.button_helper);
                    gpio_func_avtivated = 1;
                }
            }
            else {
                gpio_func_num = i;
                gpio_count = 0;
                gpio_func_avtivated = 0;
            }
            break;
        }
    }
}
#endif /* RALINK_GPIO_BUTTON_FUNC */

static void ralink_gpio_led_do_timer()
{
	int i;
	unsigned int x;
    unsigned long tmp;

	for (i = 0; i < RALINK_GPIO_NUMBER; i++) {
		ralink_gpio_led_stat[i].ticks++;
		if (ralink_gpio_led_data[i].gpio == -1) //-1 means unused
			continue;
		if (ralink_gpio_led_data[i].on == RALINK_GPIO_LED_INFINITY ||
				ralink_gpio_led_data[i].off == 0) { //always on
			__LED_ON(i);
			continue;
		}
		if (ralink_gpio_led_data[i].off == RALINK_GPIO_LED_INFINITY ||
				ralink_gpio_led_data[i].rests == RALINK_GPIO_LED_INFINITY ||
				ralink_gpio_led_data[i].on == 0 ||
				ralink_gpio_led_data[i].blinks == 0 ||
				ralink_gpio_led_data[i].times == 0) { //always off
			__LED_OFF(i);
			continue;
		}

		//led turn on or off
		if (ralink_gpio_led_data[i].blinks == RALINK_GPIO_LED_INFINITY ||
				ralink_gpio_led_data[i].rests == 0) { //always blinking
			x = ralink_gpio_led_stat[i].ticks % (ralink_gpio_led_data[i].on
					+ ralink_gpio_led_data[i].off);
		}
		else {
			unsigned int a, b, c, d, o, t;
			a = ralink_gpio_led_data[i].blinks / 2;
			b = ralink_gpio_led_data[i].rests / 2;
			c = ralink_gpio_led_data[i].blinks % 2;
			d = ralink_gpio_led_data[i].rests % 2;
			o = ralink_gpio_led_data[i].on + ralink_gpio_led_data[i].off;
			//t = blinking ticks
			t = a * o + ralink_gpio_led_data[i].on * c;
			//x = ticks % (blinking ticks + reseting ticks)
			x = ralink_gpio_led_stat[i].ticks %
				(t + b * o + ralink_gpio_led_data[i].on * d);
			//starts from 0 at reseting cycles
			if (x >= t)
				x -= t;
			x %= o;
		}
		if (x < ralink_gpio_led_data[i].on) {
			__LED_ON(i);
			if (ralink_gpio_led_stat[i].ticks && x == 0)
				ralink_gpio_led_stat[i].offs++;
#if RALINK_LED_DEBUG
			printk("t%d gpio%d on,", ralink_gpio_led_stat[i].ticks, i);
#endif
		}
		else {
			__LED_OFF(i);
			if (x == ralink_gpio_led_data[i].on)
				ralink_gpio_led_stat[i].ons++;
#if RALINK_LED_DEBUG
			printk("t%d gpio%d off,", ralink_gpio_led_stat[i].ticks, i);
#endif
		}

		//blinking or reseting
		if (ralink_gpio_led_data[i].blinks == RALINK_GPIO_LED_INFINITY ||
				ralink_gpio_led_data[i].rests == 0) { //always blinking
			continue;
		}
		else {
			x = ralink_gpio_led_stat[i].ons + ralink_gpio_led_stat[i].offs;
			if (!ralink_gpio_led_stat[i].reseting) {
				if (x == ralink_gpio_led_data[i].blinks) {
					ralink_gpio_led_stat[i].reseting = 1;
					ralink_gpio_led_stat[i].ons = 0;
					ralink_gpio_led_stat[i].offs = 0;
					ralink_gpio_led_stat[i].times++;
				}
			}
			else {
				if (x == ralink_gpio_led_data[i].rests) {
					ralink_gpio_led_stat[i].reseting = 0;
					ralink_gpio_led_stat[i].ons = 0;
					ralink_gpio_led_stat[i].offs = 0;
				}
			}
		}
		if (ralink_gpio_led_stat[i].reseting) {
			__LED_OFF(i);
#if RALINK_LED_DEBUG
			printk("reseting,");
		} else {
			printk("blinking,");
#endif
		}

		//number of times
		if (ralink_gpio_led_data[i].times != RALINK_GPIO_LED_INFINITY)
		{
			if (ralink_gpio_led_stat[i].times ==
					ralink_gpio_led_data[i].times) {
				__LED_OFF(i);
				ralink_gpio_led_data[i].gpio = -1; //stop
			}
#if RALINK_LED_DEBUG
			printk("T%d\n", ralink_gpio_led_stat[i].times);
		} else {
			printk("T@\n");
#endif
		}
	}
	//always turn the power LED on
#ifdef CONFIG_RALINK_RT2880
	__LED_ON(12);
#elif defined (CONFIG_RALINK_RT3052) || defined (CONFIG_RALINK_RT2883)
	/* EZP: Want to control power led 
     __LED_ON(9);  */
#endif
	*(volatile u32 *)(RALINK_REG_PIODATA) = ralink_gpio_led_value;
#if RALINK_LED_DEBUG
	printk("led_value= %x\n", ralink_gpio_led_value);
#endif
    /* EZP: read gpio status */
	tmp = le32_to_cpu(*(volatile u32 *)(RALINK_REG_PIODATA));

#if !defined (CONFIG_ABOCOM_5205G)
    if ((tmp & RALINK_GPIO_BUTTON_WPS) == 0)
    {
        wps_count++;
    }
    else
    {
        wps_push = 0;
        wps_count = 0;
        combo_push = 0;
    }
#endif

    if ((tmp & RALINK_GPIO_BUTTON_RESET) == 0)
    {
        reset_count++;
    }
    else
    {
        reset_count = 0;
        reset_push = 0;
        combo_push = 0;
    }

#if defined(CONFIG_BAUDTEC_RA300R4G)
    if ((tmp & RALINK_GPIO_BUTTON_WLAN) == 0)
    {
        wifi_count++;
    }
    else
    {
        wifi_count = 0;
        wifi_push = 0;
    }
#endif

    if((wps_count >= 10) && (reset_count == 0) && !wps_push) {
        /* Do WPS button things */
        button_data.button_helper_data = BUTTON_WPS;
        schedule_work(&button_data.button_helper);
        wps_count = 0;
        wps_push = 1;
#if defined(CONFIG_AMIT_CDE570_PROX)   
    } else if((wps_count == 0) && (reset_count >= 50) && !reset_push) {
#else        
    } else if((wps_count == 0) && (reset_count >= 10) && !reset_push) {
#endif        
        /* Do Reset button things */
#if defined(CONFIG_AMIT_CDW531AC) || defined(CONFIG_AMIT_CDE570)

#if defined(CONFIG_AMD16) || defined(CONFIG_AMIT_CDE570_PROX)
        button_data.button_helper_data = BUTTON_RESET;
#else        
	button_data.button_helper_data = BUTTON_WIFI_ON_OFF;
#endif

#else
        button_data.button_helper_data = BUTTON_RESET;
#endif
        schedule_work(&button_data.button_helper);
        reset_count = 0;
        reset_push = 1;
#if defined(CONFIG_AMIT_CDE570_PROX)        
    } else if ((wifi_count >= 50) && !wifi_push ) {
#else        
    } else if ((wifi_count >= 10) && !wifi_push ) {
#endif        
        button_data.button_helper_data = BUTTON_WIFI_ON_OFF;
        schedule_work(&button_data.button_helper);
        wifi_count = 0;
        wifi_push = 1;
    }
#if defined(CONFIG_AMIT_CDW531AC) || (defined(CONFIG_AMIT_CDE570) && !defined(CONFIG_AMIT_CDE570_PROX))
    else if((wps_count >= 10) && (reset_count >= 10) && !combo_push) {
        /* Do combo-button things */
#warning "combo key definition"
        button_data.button_helper_data = BUTTON_RESET;
        schedule_work(&button_data.button_helper);
        reset_count = 0;
        wps_count = 0;
        combo_push = 1;
    }
#endif
#ifdef RALINK_GPIO_BUTTON_FUNC
    ezp_gpio_handle_func_button(tmp,RALINK_GPIO_BUTTON_FUNC_MASK);
#endif /* RALINK_GPIO_BUTTON_FUNC */
	init_timer(&ralink_gpio_led_timer);
	ralink_gpio_led_timer.expires = jiffies + RALINK_GPIO_LED_FREQ;
	add_timer(&ralink_gpio_led_timer);
}


void ralink_gpio_led_init_timer(void)
{
	int i;

	for (i = 0; i < RALINK_GPIO_NUMBER; i++) {
		ralink_gpio_led_data[i].gpio = -1; //-1 means unused
#if RALINK_GPIO_LED_LOW_ACT
		ralink_gpio_led_value |= RALINK_GPIO(i);
#else
		ralink_gpio_led_value &= ~RALINK_GPIO(i);
#endif
	}

	init_timer(&ralink_gpio_led_timer);
	ralink_gpio_led_timer.function = ralink_gpio_led_do_timer;
	ralink_gpio_led_timer.expires = jiffies + RALINK_GPIO_LED_FREQ;
	add_timer(&ralink_gpio_led_timer);
}
#endif

int __init ralink_gpio_init(void)
{
	unsigned int i;
	u32 gpiomode;

#ifdef  CONFIG_DEVFS_FS
	if (devfs_register_chrdev(ralink_gpio_major, RALINK_GPIO_DEVNAME,
				&ralink_gpio_fops)) {
		printk(KERN_ERR NAME ": unable to register character device\n");
		return -EIO;
	}
	devfs_handle = devfs_register(NULL, RALINK_GPIO_DEVNAME,
			DEVFS_FL_DEFAULT, ralink_gpio_major, 0,
			S_IFCHR | S_IRUGO | S_IWUGO, &ralink_gpio_fops, NULL);
#else
	int r = 0;
	r = register_chrdev(ralink_gpio_major, RALINK_GPIO_DEVNAME,
			&ralink_gpio_fops);
	if (r < 0) {
		printk(KERN_ERR NAME ": unable to register character device\n");
		return r;
	}
	if (ralink_gpio_major == 0) {
		ralink_gpio_major = r;
		printk(KERN_DEBUG NAME ": got dynamic major %d\n", r);
	}
#endif

	//config these pins to gpio mode
	gpiomode = le32_to_cpu(*(volatile u32 *)(RALINK_REG_GPIOMODE));

#if defined (CONFIG_RALINK_RT3052) || defined (CONFIG_RALINK_RT2883)
	gpiomode &= ~0x1C;  //clear bit[2:4]UARTF_SHARE_MODE
#if defined (CONFIG_AMIT_CDM530AM) || defined (CONFIG_AMIT_CDW531AC) || \
    defined (CONFIG_AMIT_CDE570) || defined (CONFIG_AMIT_CDE550) || defined (CONFIG_BAUDTEC_RA300R1H)
    /* EZP config for mr102n ,mr105nl and amit giga board */
	gpiomode |= RALINK_GPIOMODE_JTAG;
#endif
#endif
	gpiomode |= RALINK_GPIOMODE_DFT;
	*(volatile u32 *)(RALINK_REG_GPIOMODE) = cpu_to_le32(gpiomode);

	//enable gpio interrupt
	*(volatile u32 *)(RALINK_REG_INTENA) = cpu_to_le32(RALINK_INTCTL_PIO);
	for (i = 0; i < RALINK_GPIO_NUMBER; i++) {
		ralink_gpio_info[i].irq = i;
		ralink_gpio_info[i].pid = 0;
	}

#ifdef CONFIG_RALINK_GPIO_LED
	ralink_gpio_led_init_timer();
#endif
    /* Initialize the button helper. */
    INIT_WORK(&button_data.button_helper, button_helper_action);
       
	printk("Ralink gpio driver initialized\n");
	return 0;
}

void __exit ralink_gpio_exit(void)
{
#ifdef  CONFIG_DEVFS_FS
	devfs_unregister_chrdev(ralink_gpio_major, RALINK_GPIO_DEVNAME);
	devfs_unregister(devfs_handle);
#else
	unregister_chrdev(ralink_gpio_major, RALINK_GPIO_DEVNAME);
#endif

	//config these pins to normal mode
	*(volatile u32 *)(RALINK_REG_GPIOMODE) &= ~RALINK_GPIOMODE_DFT;
	//disable gpio interrupt
	*(volatile u32 *)(RALINK_REG_INTDIS) = cpu_to_le32(RALINK_INTCTL_PIO);
#ifdef CONFIG_RALINK_GPIO_LED
	del_timer(&ralink_gpio_led_timer);
#endif
	printk("Ralink gpio driver exited\n");
}

/*
 * send a signal(SIGUSR1) to the registered user process whenever any gpio
 * interrupt comes
 * (called by interrupt handler)
 */
void ralink_gpio_notify_user(int usr)
{
	struct task_struct *p = NULL;

	if (ralink_gpio_irqnum < 0 || RALINK_GPIO_NUMBER <= ralink_gpio_irqnum) {
		printk(KERN_ERR NAME ": gpio irq number out of range\n");
		return;
	}

	//don't send any signal if pid is 0 or 1
	if ((int)ralink_gpio_info[ralink_gpio_irqnum].pid < 2)
		return;
	p = find_task_by_pid(ralink_gpio_info[ralink_gpio_irqnum].pid);
	if (NULL == p) {
		printk(KERN_ERR NAME ": no registered process to notify\n");
		return;
	}

	if (usr == 1) {
		printk(KERN_NOTICE NAME ": sending a SIGUSR1 to process %d\n",
				ralink_gpio_info[ralink_gpio_irqnum].pid);
		send_sig(SIGUSR1, p, 0);
	}
	else if (usr == 2) {
		printk(KERN_NOTICE NAME ": sending a SIGUSR2 to process %d\n",
				ralink_gpio_info[ralink_gpio_irqnum].pid);
		send_sig(SIGUSR2, p, 0);
	}
}

/*
 * 1. save the PIOINT and PIOEDGE value
 * 2. clear PIOINT by writing 1
 * (called by interrupt handler)
 */
void ralink_gpio_save_clear_intp(void)
{
	ralink_gpio_intp = le32_to_cpu(*(volatile u32 *)(RALINK_REG_PIOINT));
	ralink_gpio_edge = le32_to_cpu(*(volatile u32 *)(RALINK_REG_PIOEDGE));
	*(volatile u32 *)(RALINK_REG_PIOINT) = cpu_to_le32(0x00FFFFFF);
	*(volatile u32 *)(RALINK_REG_PIOEDGE) = cpu_to_le32(0x00FFFFFF);
}

#if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,0)
void ralink_gpio_irq_handler(unsigned int irq, struct irqaction *irqaction)
#else
irqreturn_t ralink_gpio_irq_handler(int irq, void *irqaction)
#endif
{
	struct gpio_time_record {
		unsigned long falling;
		unsigned long rising;
	};
	static struct gpio_time_record record[RALINK_GPIO_NUMBER];
	unsigned long now;
	int i;

	ralink_gpio_save_clear_intp();
	now = jiffies;
	for (i = 0; i < RALINK_GPIO_NUMBER; i++) {
		if (! (ralink_gpio_intp & (1 << i)))
			continue;
		ralink_gpio_irqnum = i;
		if (ralink_gpio_edge & (1 << i)) { //rising edge
			if (record[i].rising != 0 && time_before_eq(now,
						record[i].rising + 30L)) {
				/*
				 * If the interrupt comes in a short period,
				 * it might be floating. We ignore it.
				 */
			}
			else {
				record[i].rising = now;
				if (time_before(now, record[i].falling + 200L)) {
					//one click
					ralink_gpio_notify_user(1);
				}
				else {
					//press for several seconds
					ralink_gpio_notify_user(2);
				}
			}
		}
		else { //falling edge
			record[i].falling = now;
		}
		break;
	}

	return IRQ_HANDLED;

}

struct irqaction ralink_gpio_irqaction = {
	.handler = ralink_gpio_irq_handler,
	.flags = IRQF_SHARED,
	.mask = 0,
	.name = "ralink_gpio",
};

void __init ralink_gpio_init_irq(void)
{
	setup_irq(SURFBOARDINT_GPIO, &ralink_gpio_irqaction);
}

module_init(ralink_gpio_init);
module_exit(ralink_gpio_exit);


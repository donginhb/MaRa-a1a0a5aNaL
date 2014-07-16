/*
 *	stats
 *	Copyright (C) 2006-2007 EZ Packet Technologies
 */
/*

	rstats
	Copyright (C) 2006-2007 Jonathan Zarate

	Licensed under GNU GPL v2 or later.
	
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/signal.h>

/* for GPIO control */
#include <linux/ezp-gpio.h>
#include <linux/ioctl.h>

typedef struct {
    int gpio;           //gpio number (0 ~ 23)
    unsigned int on;        //interval of led on
    unsigned int off;       //interval of led off
    unsigned int blinks;        //number of blinking cycles
    unsigned int rests;     //number of break cycles
    unsigned int times;     //blinking times
} ralink_gpio_led_info;

/* GPIO pin define */
#define GREEN_LED   7
#define RED_LED     9
#define LOW_BAT     9
#define AC_DET      10
#define CHARGE1     0
#define CHARGE2     14
/* LED action */
#define ON          0
#define OFF         1
#define BLINK       2
/* for gpio config */
#define INIT        0
#define RED_OUT     1

const char pid_fn[] = "/var/run/power-detect.pid";
int close_daemon = 0;
int red_state = -1;
int green_state = -1;

void
gpio_config(int fd, int type){
    unsigned int cmd;
    switch (type) {
        case INIT:
            /* config direction in */
            cmd = (1L << CHARGE1);
            ioctl(fd, EZP_GPIO_SET_DIR_IN, cmd);
            cmd = (1L << CHARGE2);
            ioctl(fd, EZP_GPIO_SET_DIR_IN, cmd);
            cmd = (1L << AC_DET);
            ioctl(fd, EZP_GPIO_SET_DIR_IN, cmd);
            /* config direction out */
            cmd = (1L << GREEN_LED);
            ioctl(fd, EZP_GPIO_SET_DIR_OUT, cmd);
            cmd = (1L << RED_LED);
            ioctl(fd, EZP_GPIO_SET_DIR_OUT, cmd);
            break;
        case RED_OUT:
            /* config low battery detect pin direction to out for red led */
            cmd = (1L << RED_LED);
            ioctl(fd, EZP_GPIO_SET_DIR_OUT, cmd);
            break;
    }
}

int
ac_detect(int fd){
    int result;
    unsigned int cmd;
    cmd = (AC_DET << 24) + EZP_GPIO_READ_BIT;
    if ((ioctl(fd, cmd, &result)) == -1) {
       printf("detect AC error\n");
    }
    return result;
}

void
led(int fd, int pin, int action){
    ralink_gpio_led_info led;
    /* check action change? */
    if (pin == GREEN_LED) {
        if (green_state == action) {
            /* if pin state do not change, leave function */
            return;
        } else {
            green_state = action;
        }
    } else if (pin == RED_LED) {
        if (red_state == action) {
            /* if pin state do not change, leave function */
            return;
        } else {
            red_state = action;
        }
    }
    led.gpio = pin;
    switch(action){
        case ON:
            led.on = 1;
            led.off = 1;
            led.blinks = 0;
            led.rests = 0;
            led.times = 1;
            break;
        case OFF:
            led.on = 1;
            led.off = 0;
            led.blinks = 0;
            led.rests = 0;
            led.times = 0;
            break;
        case BLINK:
            led.on = 40;
            led.off = 1;
            led.blinks = 1;
            led.rests = 0;
            led.times = 1;
            break;
    }
    ioctl(fd, EZP_GPIO_LED_SET, &led);
}

void
battery_status(int fd){
    unsigned int cmd;
    int s1, s2;
    cmd = (CHARGE1 << 24) + EZP_GPIO_READ_BIT;
    if ((ioctl(fd, cmd, &s1)) == -1) {
       printf("get battery error\n");
    }
    cmd = (CHARGE2 << 24) + EZP_GPIO_READ_BIT;
    if ((ioctl(fd, cmd, &s2)) == -1) {
       printf("get battery error\n");
    }
    if (s1 == 0 && s2 == 1) {
        led(fd, RED_LED, ON);
    } else if (s1 == 1 && s2 == 1) {
        led(fd, RED_LED, ON);
    } else if (s1 == 0 && s2 == 0) {
        led(fd, RED_LED, OFF);
    } else {
        led(fd, RED_LED, BLINK);
    }
}

int
low_battery(int fd){
    unsigned int cmd;
    int result;
    int tmp;
    /* config gpio pin direction to in */
    cmd = (1L << LOW_BAT);
    tmp = ioctl(fd, EZP_GPIO_SET_DIR_IN, cmd);
    /* get pin statud */
    cmd = (LOW_BAT << 24) + EZP_GPIO_READ_BIT;
    if ((ioctl(fd, cmd, &result)) == -1) {
       printf("get battery status error\n");
    }
    return result;
}

static void
handle_sig_int(int sig)
{
    close_daemon = 1;
}

int
main(int argc, char *argv[])
{
    int fd;
    FILE *f;
    int low_flag = 0;
    pid_t pid, sid;

    /* Daemonize */
    if ((pid = fork()) > 0) {
        /* Parent: write a PID file. */
        if ((f = fopen(pid_fn, "w")) == NULL) {
            return 1;
        }
        fprintf(f, "%d\n", pid);
        fclose(f);
        return 0;
    }
    /* Create a new SID for the child process */
    sid = setsid();
    if (sid < 0) {
        /* Log any failures here */
        return -1;
    }
    signal(SIGTERM, handle_sig_int);
    /* Open device */
    if ((fd = open("/dev/gpio", O_RDWR)) < 0) {
        printf("Error whilst opening /dev/gpio\n");
        return -1;
    }
    /* Config gpio diretcion */
    gpio_config(fd, INIT);
    /* Polling for detect power change */
    while(!close_daemon) {
        if (ac_detect(fd) == 0) {
            /* Use AC power */
            /* config red led pin to out */
            gpio_config(fd, RED_OUT);
            low_flag = 0;
            led(fd, GREEN_LED, ON);
            battery_status(fd);
        } else {
            /* Use battery */
            if(low_flag) {
                /* battery low voltage */
                led(fd, GREEN_LED, OFF);
                led(fd, RED_LED, ON);
            } else {
                if (low_battery(fd) == 1) {
                    low_flag = 1;
                    /* config low battery pin to out */
                    gpio_config(fd, RED_OUT);
                } else {
                    led(fd, GREEN_LED, BLINK);
                }
           }
        }
        sleep(1);
    }
    unlink(pid_fn);
    return 0;
}

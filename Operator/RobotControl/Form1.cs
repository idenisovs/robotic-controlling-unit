﻿using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using Microsoft.DirectX.DirectInput;
using JoystickInterface;
using System.Net;
using System.Net.Sockets;

namespace RobotControl
{
    public partial class Form1 : Form
    {
        byte[] remdata = new byte[1024];            // Data transmission buffer 

        private JoystickInterface.Joystick jst;     // Joystick interface
        
        Socket Sock;
        IPEndPoint hostEndPoint = new IPEndPoint(IPAddress.Parse("192.168.2.1"), 4002);

        struct DataReceived             // Structure for received data
        {
            int DrvCtrlStatus;          // Chasis status code
            int ComCtrlStatus;          // Controller status code
            int Memory;                 // Controller memory level
            int Voltage;                // Voltage data
            int Temperature;            // Temperature data
        };

        struct DataSend                 // Structure for commands
        {
            public bool Status;         // Controller status request code

            public int X;
            public int Y;
            public int Z;
        };

        int X, Y, Z;

        DataReceived DtRcv;
        DataSend DtSnt;

        public Form1()
        {
            InitializeComponent();
        }

        private void Form1_Load(object sender, EventArgs e)
        {

            // Initializing joystick
            jst = new JoystickInterface.Joystick(this.Handle);
            string[] sticks = jst.FindJoysticks();
            
            if (sticks.Length > 0)
            {
                // Connect to the first found joystick device
                if (jst.AcquireJoystick(sticks[0]) == true)
                {
                    JoyCon.Text = "Connected";
                    
                    // Request the status of joystick in cycle. 
                    timer1.Enabled = true;
                }
                else
                    JoyCon.Text = "Error";
            }
            else
            {
                JoyCon.Text = "Disconnected";
            }

            // Connecting to the robot controller
            CtrlConn.Text = "Connecting...";
            try
            {

                // Making TCP/IP v4 socket
                Sock = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);

                Sock.Connect(hostEndPoint);

                // Receiving the Hello message
                Sock.Receive(remdata);
                CtrlRcv.Text = Encoding.ASCII.GetString(remdata);
                if (CtrlRcv.Text == "Hello")
                {
                    
                    CtrlConn.Text = "Connected";

                    // Making request
                    DtSnt.Status = true;
                    DtSnt.X = 0;
                    DtSnt.Y = 0;
                    DtSnt.Z = 0;

                    TmrData.Enabled = false;
                }
            }
            catch (SocketException se)
            {
                CtrlRcv.Text = se.ErrorCode.ToString();
                CtrlConn.Text = "Error";
            }

        }

        private void timer1_Tick(object sender, EventArgs e)
        {
            // Refreshing the joystick data
            jst.UpdateStatus();

            // Position of axis
            X = Convert.ToInt32((jst.AxisC - 32767) * 100 / 32767);
            Y = Convert.ToInt32(((jst.AxisD - 32767) * 100 / 32767) * (-1));
            Z = Convert.ToInt32((jst.AxisA - 32767) * 100 / 32767);

            // Axis X - left / right
            JoyX.Text = X.ToString();
            // Axis Y - forward / backward
            JoyY.Text = Y.ToString();
            // Trimmers - left / right
            JoyZ.Text = Z.ToString();
        }

        private void Form1_FormClosing(object sender, FormClosingEventArgs e)
        {
            // If we are connected, then disconnect
            if (CtrlConn.Text == "Connected")
            {
                TmrData.Enabled = false;
                Sock.Close();
            }
            // Disconnect joystick too
            jst.ReleaseJoystick();
        }

        private void TmrData_Tick(object sender, EventArgs e)
        {
            Sock.Send(Encoding.ASCII.GetBytes("Status"));
            Sock.Receive(remdata);
            CtrlRcv.Text = Encoding.ASCII.GetString(remdata);
        }

        private void label4_Click(object sender, EventArgs e)
        {

        }

        private void textBox1_TextChanged(object sender, EventArgs e)
        {

        }
    }

    public partial class Axis : UserControl
    {
        private int axisPos = 32767;
        private int axisId = 0;

        public int AxisPos
        {
            set
            {
                axisPos = value;
            }
        }
        public int AxisId
        {
            set
            {
                axisId = value;
            }
            get
            {
                return axisId;
            }
        }
    }
}

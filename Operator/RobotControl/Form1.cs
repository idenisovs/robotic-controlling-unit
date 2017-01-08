using System;
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
        byte[] remdata = new byte[1024];            // Буффер приёмника данных. 

        private JoystickInterface.Joystick jst;     // Интерфейс для работы с джойстиком
        
        // Данные для работы с сокетами.
        Socket Sock;
        IPEndPoint hostEndPoint = new IPEndPoint(IPAddress.Parse("192.168.2.1"), 4002);

        struct DataReceived             // Структура под принимаемые данные.
        {
            int DrvCtrlStatus;          // Код состояния контроллера шасси.
            int ComCtrlStatus;          // Код состояния связного контроллера.
            int Memory;                 // Объём памяти связного контроллера.
            int Voltage;                // Данные напряжения. 
            int Temperature;            // Данные температуры.
        };

        struct DataSend                 // Структура под передачу комманд.
        {
            public bool Status;         // Запрос состояния контроллера.

            public int X;             // Скорость вращения левого двигателя.
            public int Y;             // Скорость вращения левого двигателя.
            public int Z;             // Скорость вращения левого двигателя.
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

            // Инициализация джойстика.
            jst = new JoystickInterface.Joystick(this.Handle);
            string[] sticks = jst.FindJoysticks();
            
            if (sticks.Length > 0)
            {
                // Подключаемся к первому найденному джойстику.
                if (jst.AcquireJoystick(sticks[0]) == true)
                {
                    JoyCon.Text = "Connected";
                    
                    // Запускаем циклический опрос позиционеров джойстика.
                    timer1.Enabled = true;
                }
                else
                    JoyCon.Text = "Error";
            }
            else
            {
                JoyCon.Text = "Disconnected";
            }

            // Выполняем подключение к связному контроллеру.
            CtrlConn.Text = "Connecting...";
            try
            {

                // Подключение - TCP/IPv4
                Sock = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);

                Sock.Connect(hostEndPoint);

                // Приём сообщения "Hello"
                Sock.Receive(remdata);
                CtrlRcv.Text = Encoding.ASCII.GetString(remdata);
                if (CtrlRcv.Text == "Hello")
                {
                    
                    CtrlConn.Text = "Connected";

                    // Формируем запрос...
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
            // Обновление данных джойстика
            jst.UpdateStatus();

            // Позиционеры
            X = Convert.ToInt32((jst.AxisC - 32767) * 100 / 32767);
            Y = Convert.ToInt32(((jst.AxisD - 32767) * 100 / 32767) * (-1));
            Z = Convert.ToInt32((jst.AxisA - 32767) * 100 / 32767);

            // Ось Х - левый / правый
            JoyX.Text = X.ToString();
            // Ось У - вперёд / назад.
            JoyY.Text = Y.ToString();
            // Триммер - левый / правый.
            JoyZ.Text = Z.ToString();
        }

        private void Form1_FormClosing(object sender, FormClosingEventArgs e)
        {
            // Если подключенны к контроллеру шасси - отключаемся.
            if (CtrlConn.Text == "Connected")
            {
                TmrData.Enabled = false;
                Sock.Close();
            }
            // Отключаем джойстик. 
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

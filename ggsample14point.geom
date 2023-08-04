#version 410 core

// 光源
layout (std140) uniform Light
{
  vec4 lamb;                                          // 環境光成分
  vec4 ldiff;                                         // 拡散反射光成分
  vec4 lspec;                                         // 鏡面反射光成分
  vec4 lpos;                                          // 位置
};

// 材質
layout (std140) uniform Material
{
  vec4 kamb;                                          // 環境光の反射係数
  vec4 kdiff;                                         // 拡散反射係数
  vec4 kspec;                                         // 鏡面反射係数
  float kshi;                                         // 輝き係数
};
// 四面体の頂点位置
const vec4 position[] = vec4[](
  vec4( 0.0,  0.1, 0.0, 0.0),
  vec4( 0.0,  0.0, 0.1, 0.0),
  vec4( 0.1,  0.0, 0.0, 0.0),

  vec4( 0.0,  0.0, -0.1, 0.0),
  vec4( 0.0,  -0.1, 0.0, 0.0),
  vec4( -0.1, 0.0, 0.0, 0.0)
  //vec4( 0.0, 0.0, 0.1, 0.0),
  //vec4( 0.0, 0.1, 0.0, 0.0),
  //vec4( 0.0, 0.0, -0.1, 0.0),
  //vec4( 0.1, 0.0, 0.0, 0.0)

  //vec4( 0.1,  0.0, 0.0, 0.0),
  //vec4( 0.0,  -0.1, 0.0, 0.0),
  //vec4( 0.0,  0.0, -0.1, 0.0)
  );

//四面体の位置（ここの頂点のつけ方が悪い？
const vec4 position2[] = vec4[](
   vec4(0.0, 0.0, -0.1, 0.0),
   vec4(0.0, 0.1, 0.0, 0.0),
   vec4(-0.1, 0.0, 0.0, 0.0),
   vec4(-0.1, 0.0, 0.0, 0.0)
/**
   vec4(0.0, 0.0, -0.1, 0.0),
   vec4(0.0, 0.1, 0.0, 0.0),
   vec4(-0.1, 0.0, 0.0, 0.0),
   vec4(0.0, 0.0, 0.1, 0.0),
   vec4(0.0, -0.1, 0.0, 0.0),
   vec4(0.1, 0.0, 0.0, 0.0)
  /**/
);

// 四面体の頂点色
const vec4 color[] = vec4[](
  vec4(1.0, 0.0, 0.0, 1.0),
  vec4(0.0, 1.0, 0.0, 1.0),
  vec4(0.0, 0.0, 1.0, 1.0),
  vec4(1.0, 0.0, 0.0, 1.0),
  vec4(0.0, 1.0, 0.0, 1.0),
  vec4(0.0, 0.0, 1.0, 1.0)
  //vec4(1.0, 0.0, 0.0, 1.0),
  //vec4(0.0, 1.0, 0.0, 1.0),
  //vec4(0.0, 0.0, 1.0, 1.0),
  //vec4(1.0, 0.0, 0.0, 1.0)
  //vec4(0.0, 0.0, 1.0, 1.0),
  //vec4(1.0, 0.0, 0.0, 1.0),
  //vec4(0.0, 1.0, 0.0, 1.0),
  //vec4(0.0, 0.0, 1.0, 1.0)
  );

 const vec4 color2[] = vec4[](
  vec4(1.0, 0.0, 0.0, 1.0),
  vec4(0.0, 1.0, 0.0, 1.0),
  vec4(0.0, 0.0, 1.0, 1.0),
  vec4(1.0, 0.0, 0.0, 1.0),
  vec4(0.0, 1.0, 0.0, 1.0),
  vec4(0.0, 0.0, 1.0, 1.0)
  //vec4(1.0, 0.0, 0.0, 1.0),
  //vec4(0.0, 1.0, 0.0, 1.0),
  //vec4(0.0, 0.0, 1.0, 1.0),
  //vec4(1.0, 0.0, 0.0, 1.0)
  //vec4(0.0, 0.0, 1.0, 1.0),
  //vec4(1.0, 0.0, 0.0, 1.0),
  //vec4(0.0, 1.0, 0.0, 1.0),
  //vec4(0.0, 0.0, 1.0, 1.0)
  );

// 変換行列
uniform mat4 mv;                                      // モデルビュー変換行列
uniform mat4 mp;                                      // 投影変換行列
uniform mat4 mn;                                      // 法線ベクトルの変換行列

// ジオメトリシェーダに入力される図形要素
layout(points) in;

// ジオメトリシェーダから出力する図形要素と最大頂点数
layout(triangle_strip, max_vertices = 85) out;

// ラスタライザに送る頂点属性
out vec4 iamb;                                        // 環境光の反射光強度
out vec4 idiff;                                       // 拡散反射光強度
out vec4 ispec;                                       // 鏡面反射光強度

//layout (location = 1) in vec4 nv;                     // 頂点の法線ベクトル

void main()
{
  // 点の位置をモデルビュー変換する
  vec4 p = mv * gl_in[0].gl_Position;
  vec3 v = -normalize(p.xyz / p.w);                   // 視線ベクトル
  vec3 l = normalize((lpos * p.w - p * lpos.w).xyz);  // 光線ベクトル
  vec3 n = normalize((mn * color[0]).xyz);                // 法線ベクトル
  float lsize = sqrt(l.x * l.x + l.y * l.y + l.z * l.z);//光線ベクトルの大きさ
  float vsize = sqrt(v.x * v.x + v.y * v.y + v.z * v.z);//視線ベクトルの大きさ
  vec3 h = (l + v)/(lsize + vsize);// 中間ベクトル

  float NL = n.x * l.x + n.y * l.y + n.z * l.z;
  float NH = n.x * h.x + n.y * h.y + n.z * h.z;

  //ジオメトリシェーダ
  //glProgramParameteri(program, GL_GEOMETRY_TYPE, GL_POINTS);
  //glProgramParameteri(program, GL_GEOMETRY_TYPE, GL_POINTS);

  /**/
  for (int i = 0; i < position.length(); ++i)
  {
    // モデルビュー変換後の点の位置を中心として頂点位置を求め投影変換する
    gl_Position = mp * (p + position[i]);

    iamb = vec4(kamb.x * lamb.x , kamb.y * lamb.y , kamb.z * lamb.z, kamb.w * lamb.w);
    vec4 idiff = max(NL, 0) * vec4(kdiff.x * ldiff.x , kdiff.y * ldiff.y, kdiff.z * ldiff.z, kdiff.w * ldiff.w);
    ispec = pow(max(NH, 0), kshi) * vec4(kspec.x * lspec.x , kspec.y * lspec.y, kspec.z * lspec.z, kspec.w * lspec.w);;

    EmitVertex();
  }

  EndPrimitive();
  /**/

  /**　
  for (int i = 0; i < position2.length(); ++i)
  {
    // モデルビュー変換後の点の位置を中心として頂点位置を求め投影変換する
    gl_Position = mp * (p + position2[i]);

    iamb = vec4(0.0);
    idiff = color2[i];
    ispec = vec4(0.0);

    EmitVertex();
  }

  EndPrimitive();
  /**/
}

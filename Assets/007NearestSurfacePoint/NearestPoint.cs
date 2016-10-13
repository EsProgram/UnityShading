using System;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class NearestPoint : MonoBehaviour
{
	[SerializeField]
	private Transform pObj;

	[SerializeField]
	private Transform pdObj;

	private Mesh mesh;
	private int[] triangles;
	private Vector3[] vertices;

	private void Start()
	{
		mesh = GetComponent<MeshFilter>().sharedMesh;
		triangles = mesh.triangles;
		vertices = mesh.vertices;
	}

	private void Update()
	{
		var p = transform.worldToLocalMatrix.MultiplyPoint(pObj.position);

		//頂点の中で一番近いものを含む三角形を取得
		var tris = GetNearestVerticesTriangle(p, vertices, triangles);

		//それぞれの三角形空間でそれっぽいp'を計算
		var pds = new List<Vector3>();
		for(int i = 0; i < tris.Length; i += 3)
		{
			var i0 = i;
			var i1 = i + 1;
			var i2 = i + 2;
			pds.Add(TriangleSpaceProjection(p, tris[i0], tris[i1], tris[i2]));
		}

		//p'が三角形内部にない場合は一番近い頂点位置をp'に設定（今はやらない）

		//pに一番近いp'が求めたかったオブジェクト表面
		var pd = pds.OrderBy(t => Vector3.Distance(p, t)).First();

		pdObj.position = transform.localToWorldMatrix.MultiplyPoint(pd);
	}

	/// <summary>
	/// pに最も近い頂点を持つTriangleを返す
	/// </summary>
	private Vector3[] GetNearestVerticesTriangle(Vector3 p, Vector3[] vertices, int[] triangles)
	{
		List<Vector3> ret = new List<Vector3>();

		int nearestIndex = triangles[0];
		float nearestDistance = Vector3.Distance(vertices[nearestIndex], p);

		for(int i = 0; i < vertices.Length; ++i)
		{
			float distance = Vector3.Distance(vertices[i], p);
			if(distance < nearestDistance)
			{
				nearestDistance = distance;
				nearestIndex = i;
			}
		}
		//return nearestIndex;

		for(int i = 0; i < triangles.Length; ++i)
		{
			if(triangles[i] == nearestIndex)
			{
				var m = i % 3;
				int i0 = i, i1 = 0, i2 = 0;
				switch(m)
				{
					case 0:
						i1 = i + 1;
						i2 = i + 2;
						break;

					case 1:
						i1 = i - 1;
						i2 = i + 1;
						break;

					case 2:
						i1 = i - 1;
						i2 = i - 2;
						break;

					default:
						break;
				}
				ret.Add(vertices[triangles[i0]]);
				ret.Add(vertices[triangles[i1]]);
				ret.Add(vertices[triangles[i2]]);
			}
		}
		return ret.ToArray();
	}

	/// <summary>
	/// 点pを三角形空間内に投影した点を返す
	/// </summary>
	/// <param name="p">投影する点</param>
	/// <param name="t1">三角形頂点</param>
	/// <param name="t2">三角形頂点</param>
	/// <param name="t3">三角形頂点</param>
	/// <returns>投影後の三角形空間上の点</returns>
	private Vector3 TriangleSpaceProjection(Vector3 p, Vector3 t1, Vector3 t2, Vector3 t3)
	{
		var g = (t1 + t2 + t3) / 3;
		var pa = t1 - p;
		var pb = t2 - p;
		var pc = t3 - p;
		var ga = t1 - g;
		var gb = t2 - g;
		var gc = t3 - g;

		var _pa_ = pa.magnitude;
		var _pb_ = pb.magnitude;
		var _pc_ = pc.magnitude;

		var lmin = Mathf.Min(Mathf.Min(_pa_, _pb_), _pc_);

		Func<float, float, float> k = (t, u) => (t - lmin + u - lmin) / 2;

		var A = k(_pb_, _pc_);
		var B = k(_pc_, _pa_);
		var C = k(_pa_, _pb_);
		var pd = g + (ga * A + gb * B + gc * C);
		return pd;
	}
}